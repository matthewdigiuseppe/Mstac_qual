# model-checks.R — is the model doing more harm than good?
# Bundled with QualStack (/qualstack:robustness, /qualstack:model-review). Copy to
# code/model-checks.R and source() it from code/05-robustness.R. Base R plus
# CausalQueries. The four checks follow Humphreys & Jacobs (2023, ch. 16):
#
#   qs_implied_independencies()  the conditional independencies the DAG implies
#                                among observed nodes: the model's testable claims.
#   qs_ci_tests()                each implied independence in the data: the
#                                difference in Pr(A = 1) between B = 1 and B = 0
#                                within every stratum of the conditioning set,
#                                with a Fisher exact p-value. A frequentist check
#                                of the Markov condition.
#   qs_ppc()                     posterior predictive (Bayesian p) checks, with
#                                statistics that target dependence, not only means.
#                                Not calibrated: read as a warning light.
#   qs_loo()                     leave-one-out likelihood by data pattern, for
#                                comparing models: one Stan run per distinct pattern.
#   qs_sensitivity()             the same queries under model variants, side by
#                                side, flagging answers that change sign or cross 0.5.

library(CausalQueries)

# ---- graph utilities (identical to clue-diagnosis.R) ---------------------------------

qs_graph <- function(model) {
  pd <- grab(model, "parents_df")
  nodes <- as.character(pd$node)
  edges <- data.frame(from = character(0), to = character(0))
  for (i in seq_len(nrow(pd))) {
    ps <- trimws(strsplit(as.character(pd$parent_nodes[i]), ",")[[1]])
    ps <- ps[nzchar(ps)]
    if (length(ps)) edges <- rbind(edges, data.frame(from = ps, to = nodes[i]))
    edges <- rbind(edges, data.frame(from = paste0("theta_", nodes[i]), to = nodes[i]))
  }
  # Unobserved confounding A <-> B: a latent common cause of theta_A and theta_B.
  stmt <- as.character(grab(model, "statement"))
  for (pair in regmatches(stmt, gregexpr("[A-Za-z0-9_.]+\\s*<->\\s*[A-Za-z0-9_.]+", stmt))[[1]]) {
    ab <- trimws(strsplit(pair, "<->")[[1]])
    u <- paste0("U_", ab[1], "_", ab[2])
    edges <- rbind(edges, data.frame(from = u, to = paste0("theta_", ab)))
  }
  unique(edges)
}

# TRUE when some node in `to` is d-connected to some node in `from` given `given`
# (reachability along active trails; Koller & Friedman 2009, Algorithm 3.1).
qs_dconnected <- function(edges, from, to, given = character(0)) {
  parents  <- function(v) edges$from[edges$to == v]
  children <- function(v) edges$to[edges$from == v]
  anc <- character(0); frontier <- given
  while (length(frontier)) {               # given nodes and all their ancestors
    v <- frontier[1]; frontier <- frontier[-1]
    if (!(v %in% anc)) { anc <- c(anc, v); frontier <- c(frontier, parents(v)) }
  }
  visited <- character(0); reachable <- character(0)
  queue <- lapply(from, function(v) list(node = v, dir = "up"))
  while (length(queue)) {
    cur <- queue[[1]]; queue <- queue[-1]
    key <- paste(cur$node, cur$dir)
    if (key %in% visited) next
    visited <- c(visited, key)
    v <- cur$node
    if (!(v %in% given)) reachable <- c(reachable, v)
    if (cur$dir == "up" && !(v %in% given)) {
      queue <- c(queue, lapply(parents(v), function(p) list(node = p, dir = "up")),
                 lapply(children(v), function(ch) list(node = ch, dir = "down")))
    } else if (cur$dir == "down") {
      if (!(v %in% given))
        queue <- c(queue, lapply(children(v), function(ch) list(node = ch, dir = "down")))
      if (v %in% anc)
        queue <- c(queue, lapply(parents(v), function(p) list(node = p, dir = "up")))
    }
  }
  any(to %in% reachable)
}

# ---- 1. implied conditional independencies --------------------------------------------

# One claim per pair of non-adjacent nodes: the later node is independent of the
# earlier one given the later node's parents (the local Markov condition), or,
# where confounding blocks that, the smallest of a few other candidate sets.
qs_implied_independencies <- function(model) {
  edges <- qs_graph(model)
  nodes <- as.character(grab(model, "nodes"))           # in causal order
  pa <- function(v) intersect(edges$from[edges$to == v], nodes)
  out <- list()
  for (i in seq_along(nodes)) for (j in seq_along(nodes)) if (i < j) {
    a <- nodes[j]; b <- nodes[i]                         # a is later
    if (b %in% pa(a) || a %in% pa(b)) next
    cands <- unique(list(pa(a), character(0), union(pa(a), pa(b)), pa(b)))
    cands <- lapply(cands, setdiff, c(a, b))
    hit <- Filter(function(s) !qs_dconnected(edges, a, b, s), cands)
    if (length(hit)) {
      s <- hit[[which.min(lengths(hit))]]
      out[[length(out) + 1]] <- data.frame(a = a, b = b, given = paste(s, collapse = ", "),
                                           claim = paste0(a, " _||_ ", b,
                                                          if (length(s)) paste0(" | ", paste(s, collapse = ", ")) else ""))
    } else {
      out[[length(out) + 1]] <- data.frame(a = a, b = b, given = NA,
                                           claim = paste0(a, " and ", b, ": no simple implied independence (confounding)"))
    }
  }
  if (!length(out)) return(data.frame(a = character(0), b = character(0), given = character(0), claim = character(0)))
  do.call(rbind, out)
}

# Test each implied independence in `data` (one row per case, 0/1/NA). Use data
# that were not selected on a collider: cases kept because of their outcome
# cannot test independencies that hold unconditionally or at the other outcome.
qs_ci_tests <- function(model, data, independencies = qs_implied_independencies(model)) {
  edges <- qs_graph(model)
  nodes <- as.character(grab(model, "nodes"))
  rows <- list()
  for (k in seq_len(nrow(independencies))) {
    if (is.na(independencies$given[k])) next
    a <- independencies$a[k]; b <- independencies$b[k]
    s <- if (nzchar(independencies$given[k])) trimws(strsplit(independencies$given[k], ",")[[1]]) else character(0)
    keep <- stats::complete.cases(data[, c(a, b, s), drop = FALSE])
    # Cases that observe a, b and s may all share the value of another node (clues
    # gathered only where the outcome occurred). If conditioning on that node opens
    # a path between a and b, the test is invalid in these data.
    selected <- Filter(function(w) {
      v <- unique(stats::na.omit(data[[w]][keep]))
      length(v) == 1 && length(unique(stats::na.omit(data[[w]]))) > 1 &&
        qs_dconnected(edges, a, b, c(s, w))
    }, setdiff(nodes, c(a, b, s)))
    if (length(selected)) {
      rows[[length(rows) + 1]] <- data.frame(
        claim = independencies$claim[k], stratum = "-", n = sum(keep), diff = NA, p_fisher = NA,
        note = paste0("invalid here: every case observing ", a, " and ", b, " has the same ",
                      paste(selected, collapse = ", "), ", and conditioning on it opens a path"))
      next
    }
    d <- data[keep, c(a, b, s), drop = FALSE]
    strata <- if (length(s)) split(d, d[, s, drop = FALSE], drop = TRUE) else list(all = d)
    for (nm in names(strata)) {
      g <- strata[[nm]]
      p1 <- mean(g[[a]][g[[b]] == 1]); p0 <- mean(g[[a]][g[[b]] == 0])
      tab <- table(factor(g[[a]], 0:1), factor(g[[b]], 0:1))
      p <- if (all(dim(tab) == 2) && all(rowSums(tab) > 0) && all(colSums(tab) > 0))
        stats::fisher.test(tab)$p.value else NA
      rows[[length(rows) + 1]] <- data.frame(
        claim = independencies$claim[k],
        stratum = if (length(s)) paste(paste0(s, "=", unlist(g[1, s])), collapse = ", ") else "-",
        n = nrow(g), diff = p1 - p0, p_fisher = p,
        note = if (is.na(p)) "untestable here: a margin is constant" else "")
    }
  }
  if (!length(rows)) return(NULL)
  do.call(rbind, rows)
}

# ---- 2. posterior predictive checks --------------------------------------------------------

# Two-sided Bayesian p-value (Humphreys & Jacobs 2023, sec. 16.1.2).
qs_p_two_sided <- function(T, t) {
  T <- T[is.finite(T)]
  lo <- mean(T) - abs(mean(T) - t); hi <- mean(T) + abs(mean(T) - t)
  mean(T <= lo) + mean(T >= hi)
}

# Default statistics: the mean of every node, and the correlation of every pair
# of nodes (on cases observing both). Pass your own as a named list of
# functions of a data frame.
qs_default_stats <- function(nodes) {
  st <- list()
  for (v in nodes) st[[paste0("mean(", v, ")")]] <- local({ v <- v; function(d) mean(d[[v]], na.rm = TRUE) })
  if (length(nodes) > 1) for (p in utils::combn(nodes, 2, simplify = FALSE))
    st[[paste0("cor(", p[1], ",", p[2], ")")]] <- local({ p <- p; function(d) {
      ok <- stats::complete.cases(d[, p]); x <- d[ok, p[1]]; y <- d[ok, p[2]]
      if (sum(ok) < 3 || stats::sd(x) == 0 || stats::sd(y) == 0) NA else stats::cor(x, y) } })
  st
}

# Replicate data sets from the posterior with the observed data's missingness:
# within each combination of the fully observed nodes, a replicate case gets a
# pattern of observed clues drawn from the patterns observed there. That is the
# "selection on observed values" assumption the analysis itself makes.
qs_ppc <- function(updated, data, stats = NULL, sims = 500, seed = 1) {
  set.seed(seed)
  nodes <- as.character(grab(updated, "nodes"))
  data <- data[, nodes, drop = FALSE]
  if (is.null(stats)) stats <- qs_default_stats(nodes)
  full <- nodes[colSums(is.na(data)) == 0]
  part <- setdiff(nodes, full)
  pattern_of <- function(d) if (length(part)) apply(1L * !is.na(d[, part, drop = FALSE]), 1, paste, collapse = "") else rep("", nrow(d))
  key_of <- function(d) if (length(full)) apply(d[, full, drop = FALSE], 1, paste, collapse = "") else rep("", nrow(d))
  obs_pat <- pattern_of(data); obs_key <- key_of(data)
  observed <- vapply(stats, function(f) f(data), numeric(1))
  reps <- t(replicate(sims, {
    r <- make_data(updated, n = nrow(data), param_type = "posterior_draw")[, nodes, drop = FALSE]
    if (length(part)) {
      rk <- key_of(r)
      for (i in seq_len(nrow(r))) {
        pool <- obs_pat[obs_key == rk[i]]
        if (!length(pool)) pool <- obs_pat
        pat <- strsplit(pool[sample.int(length(pool), 1)], "")[[1]] == "1"
        r[i, part[!pat]] <- NA
      }
    }
    vapply(stats, function(f) f(r), numeric(1))
  }))
  if (length(stats) == 1) reps <- matrix(reps, ncol = 1, dimnames = list(NULL, names(stats)))
  out <- data.frame(
    stat = names(stats), observed = observed,
    rep_mean = apply(reps, 2, mean, na.rm = TRUE),
    rep_low = apply(reps, 2, stats::quantile, 0.025, na.rm = TRUE),
    rep_high = apply(reps, 2, stats::quantile, 0.975, na.rm = TRUE),
    p_two_sided = vapply(seq_along(stats), function(j) qs_p_two_sided(reps[, j], observed[j]), numeric(1)),
    row.names = NULL)
  attr(out, "draws") <- reps
  out
}

# ---- 3. leave-one-out likelihood ---------------------------------------------------------------

# For each distinct data pattern (values on the observed nodes, NA where not
# observed): drop one case with that pattern, update on the rest, and record
# the posterior predictive probability of the dropped pattern. The LOO
# likelihood is the product over cases. Compare models with log10_loo: a
# difference of 2 means the better model predicted the left-out cases 100
# times better. Expect the asymmetry: a permissive model loses little when a
# stricter one is true; a strict model can fail badly when it is wrong.
qs_loo <- function(model, data, iter = 4000, chains = 4, seed = 1) {
  nodes <- as.character(grab(model, "nodes"))
  data <- data[, nodes, drop = FALSE]
  sig <- apply(data, 1, function(r) paste(ifelse(is.na(r), "?", r), collapse = ""))
  pats <- unique(sig)
  strategy <- apply(!is.na(data), 1, paste, collapse = "")
  rows <- lapply(pats, function(p) {
    i <- which(sig == p)[1]
    obs <- nodes[!is.na(unlist(data[i, ]))]
    stmt <- paste0(obs, "==", unlist(data[i, obs]), collapse = " & ")
    set.seed(seed)
    fit <- suppressMessages(update_model(model, data[-i, , drop = FALSE], refresh = 0,
                                         iter = iter, chains = chains))
    pr <- mean(query_distribution(fit, queries = list(p = stmt), using = "posteriors")[[1]])
    data.frame(pattern = p, observed_nodes = paste(obs, collapse = ","), count = sum(sig == p),
               loo_prob = pr, expected = pr * sum(strategy == strategy[i]))
  })
  tab <- do.call(rbind, rows)
  attr(tab, "log10_loo") <- sum(tab$count * log10(tab$loo_prob))
  tab
}

# ---- 4. sensitivity across model variants -----------------------------------------------------------

# models: named list; the first is the base model. With `data`, each is
# updated on it (same seed) and queried with using = "posteriors"; without,
# queried with `using` ("parameters" for single-case process tracing).
# Flags: sign = the variant's answer has the other sign from the base (effects);
# half = it falls on the other side of 0.5 (probabilities); base_determined =
# the base model's answer is fixed by its restrictions (no uncertainty), so it
# reports an assumption, not a finding.
qs_sensitivity <- function(models, queries, given = list(TRUE), data = NULL,
                           using = if (is.null(data)) "parameters" else "posteriors",
                           case_level = FALSE, iter = 4000, chains = 4, seed = 1) {
  res <- lapply(names(models), function(nm) {
    m <- models[[nm]]
    if (!is.null(data)) {
      set.seed(seed)
      m <- suppressMessages(update_model(m, data, refresh = 0, iter = iter, chains = chains))
    }
    q <- as.data.frame(query_model(m, queries = queries, given = given, using = using,
                                   case_level = case_level, expand_grid = TRUE))
    cbind(model = nm, q)
  })
  long <- do.call(rbind, res)
  key <- paste(long$label, long$given)
  base <- long[long$model == names(models)[1], ]
  b <- setNames(base$mean, paste(base$label, base$given))[key]
  bsd <- if ("sd" %in% names(base)) setNames(base$sd, paste(base$label, base$given))[key] else rep(NA, length(key))
  long$change <- long$mean - b
  long$sign_flip <- abs(long$mean) > 0.005 & abs(b) > 0.005 & sign(long$mean) != sign(b)
  long$crosses_half <- (long$mean - 0.5) * (b - 0.5) < 0
  # With no posterior sd (parameters, case-level), an answer of exactly 0 or 1 is
  # fixed by the model; with one, a zero sd is.
  long$base_determined <- ifelse(is.na(bsd), abs(b) < 1e-9 | abs(b - 1) < 1e-9, bsd < 1e-9)
  long
}
