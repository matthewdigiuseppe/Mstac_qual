# case-diagnosis.R — which cases to process trace, and whether to go wide or deep.
# Bundled with QualStack (/qualstack:case-select). Copy to code/case-diagnosis.R
# and source() it from code/02-design.R. Base R plus CausalQueries.
#
#   qs_case_strategies()  expected posterior variance of a query under each
#                         case-selection strategy: seek the clue(s) in cases
#                         already in the data, chosen by their observed values
#                         (Humphreys & Jacobs 2023, ch. 13, four-step procedure).
#   qs_wide_deep()        simulation of breadth (more cases with the cross-case
#                         nodes) against depth (clues in some of them), with
#                         costs (Humphreys & Jacobs 2023, ch. 14). Slow: one
#                         Stan run per simulated data set.
#
# qs_case_strategies() needs the model updated once on the data in hand: every
# case, with NA for clues not yet sought. Finding clue values k in the selected
# cases multiplies each posterior draw of lambda by Pr(k | the cases' observed
# values, lambda), so the posterior after each possible finding is a
# reweighting of the same draws and needs no further Stan runs. The expected
# posterior variance is exact for those draws; the effective sample size (ess)
# of each reweighting is reported, and a small one (under a few hundred) calls
# for more iterations in update_model().

library(CausalQueries)

qs_wvar <- function(x, w) { w <- w / sum(w); m <- sum(w * x); sum(w * (x - m)^2) }

# updated:    a model updated on the data in hand (update_model()).
# query:      e.g. "Y[X=1] - Y[X=0]" (ATE), or "Y[X=1] > Y[X=0]" with
#             given = "X==1 & Y==1" (share of X=1, Y=1 cases where X caused Y).
# strategies: named list; each element has one condition per case to be traced,
#             e.g. list(on = c("X==1 & Y==1", "X==0 & Y==0"),
#                       off = c("X==1 & Y==0", "X==0 & Y==1"),
#                       two_pos = c("X==1 & Y==1", "X==1 & Y==1")).
# clues:      the node(s) sought in every selected case, e.g. "M".
# data:       optional; the data the model was updated on, to check that each
#             strategy's cells hold enough cases whose clues are still NA.
qs_case_strategies <- function(updated, query, strategies, clues, given = NULL,
                               data = NULL) {
  target <- query_distribution(updated, queries = list(q = query), given = given,
                               using = "posteriors")[[1]]
  ok <- is.finite(target)
  if (!all(ok)) warning(sum(!ok), " posterior draws give an undefined query; dropped")
  prior_mean <- mean(target[ok]); prior_var <- mean((target[ok] - prior_mean)^2)

  # Pr(each clue pattern | cell, lambda), one column per pattern, one row per draw.
  grid <- expand.grid(rep(list(0:1), length(clues)))
  found <- apply(grid, 1, function(v) paste0(clues, "==", v, collapse = " & "))
  shown <- apply(grid, 1, function(v) paste0(clues, "=", v, collapse = ","))
  cells <- unique(unlist(strategies))
  cell_probs <- lapply(setNames(cells, cells), function(cl) {
    as.matrix(query_distribution(updated, queries = as.list(found),
                                 given = rep(cl, length(found)), using = "posteriors"))[ok, , drop = FALSE]
  })

  if (!is.null(data)) for (s in names(strategies)) {
    need <- table(strategies[[s]])
    for (cl in names(need)) {
      hit <- with(data, eval(parse(text = cl)))
      open <- rowSums(!is.na(data[, clues, drop = FALSE])) == 0
      have <- sum(hit & open, na.rm = TRUE)
      if (have < need[[cl]])
        warning("strategy '", s, "' needs ", need[[cl]], " case(s) with ", cl,
                " and the clues unobserved; the data have ", have)
    }
  }

  pattern_rows <- list()
  rows <- lapply(names(strategies), function(s) {
    cs <- strategies[[s]]
    combos <- expand.grid(rep(list(seq_along(found)), length(cs)))
    pats <- lapply(seq_len(nrow(combos)), function(i) {
      idx <- unlist(combos[i, ])
      w <- Reduce(`*`, lapply(seq_along(cs), function(j) cell_probs[[cs[j]]][, idx[j]]))
      p <- mean(w)
      key <- paste(sort(paste0("[", cs, "] ", shown[idx])), collapse = " + ")
      if (p <= 0) return(data.frame(pattern = key, prob = 0, post_mean = NA,
                                    post_var = 0, ess = NA))
      wn <- w / sum(w)
      data.frame(pattern = key, prob = p, post_mean = sum(wn * target[ok]),
                 post_var = qs_wvar(target[ok], w), ess = 1 / sum(wn^2))
    })
    pats <- do.call(rbind, pats)
    # The same findings in a different order are one pattern.
    agg <- do.call(rbind, lapply(split(pats, pats$pattern), function(g)
      data.frame(pattern = g$pattern[1], prob = sum(g$prob), post_mean = g$post_mean[1],
                 post_var = g$post_var[1], ess = g$ess[1])))
    agg <- agg[order(-agg$prob), ]
    pattern_rows[[s]] <<- cbind(strategy = s, agg, row.names = NULL)
    epv <- sum(agg$prob * agg$post_var)
    data.frame(strategy = s, cases = paste(cs, collapse = " + "), clues = paste(clues, collapse = " + "),
               prior_mean = prior_mean, prior_var = prior_var, exp_post_var = epv,
               exp_learning = if (prior_var > 0) 1 - epv / prior_var else 0,
               min_ess = suppressWarnings(min(agg$ess[agg$prob >= 0.01], na.rm = TRUE)))
  })
  out <- do.call(rbind, rows)
  attr(out, "patterns") <- do.call(rbind, pattern_rows)
  out
}

# Breadth against depth by simulation (Humphreys & Jacobs 2023, sec. 14.2).
# For each design (wide = number of cases with the cross-case nodes, deep =
# number of those cases with the clues too), draw `sims` data sets from the
# model (priors, or the posterior on `observed`), update on each, and average
# the posterior variance of the query. With `observed`, the deep cases are drawn
# from the new cases; to choose among cases already in hand, use
# qs_case_strategies(). Costs: wide * cost_wide + deep * cost_deep.
qs_wide_deep <- function(model, query, cross_nodes, clues, wide, deep, given = NULL,
                         observed = NULL, sims = 20, cost_wide = 1, cost_deep = 0,
                         iter = 2000, chains = 2, seed = 1) {
  set.seed(seed)
  source_model <- model
  param_type <- "prior_draw"
  if (!is.null(observed)) {
    source_model <- suppressMessages(update_model(model, observed, refresh = 0,
                                                  iter = iter, chains = chains))
    param_type <- "posterior_draw"
  }
  designs <- expand.grid(wide = wide, deep = deep)
  designs <- designs[designs$deep <= designs$wide & designs$wide > 0, ]
  if (!is.null(observed)) for (v in setdiff(grab(model, "nodes"), names(observed))) observed[[v]] <- NA
  res <- lapply(seq_len(nrow(designs)), function(i) {
    w <- designs$wide[i]; d <- designs$deep[i]
    vars <- numeric(0); warned <- 0
    for (s in seq_len(sims)) {
      new <- if (d > 0) {
        make_data(source_model, n = w, nodes = list(cross_nodes, clues),
                  n_steps = list(w, d), param_type = param_type)
      } else {
        make_data(source_model, n = w, nodes = cross_nodes, param_type = param_type)
      }
      df <- if (is.null(observed)) new else rbind(observed[, names(new)], new)
      fit <- withCallingHandlers(
        suppressMessages(update_model(model, df, refresh = 0, iter = iter, chains = chains)),
        warning = function(wn) { warned <<- warned + 1; invokeRestart("muffleWarning") })
      qm <- as.data.frame(query_model(fit, queries = list(q = query), given = given,
                                      using = "posteriors"))
      vars <- c(vars, qm$sd[1]^2)
    }
    data.frame(wide = w, deep = d, mean_post_var = mean(vars),
               se = sd(vars) / sqrt(length(vars)), cost = w * cost_wide + d * cost_deep,
               sims = sims, runs_with_warnings = warned)
  })
  out <- do.call(rbind, res)
  base <- out$mean_post_var[out$wide == min(out$wide) & out$deep == 0][1]
  out$reduction <- 1 - out$mean_post_var / base
  out
}
