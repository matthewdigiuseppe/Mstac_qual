# trace-case.R — how far each piece of evidence moved belief about one case.
# Bundled with QualStack (/qualstack:process-trace). Copy to code/trace-case.R
# and source() it from code/04-update.R (or run it on its own for one case).
# Base R plus CausalQueries.
#
#   qs_trace_case()     model-based: the case query before any clue, after each
#                       clue in the order sought (the evidence path), and the
#                       posterior had each clue come out the other way with the
#                       others as found (the counterfactual table).
#   qs_informal_trace() informal Bayesian process tracing (model.formal: false,
#                       or evidence the model does not represent): stated
#                       likelihoods, as ranges, combined in log-odds, with the
#                       weight of each item in decibels (Fairfield & Charman 2022).
#
# Which question a model-based number answers (mixed-methods.md):
#   using = "parameters"  an untrained model at its stored parameters (set them
#                         to the prior means): single-case process tracing.
#   using = "posteriors", case_level = FALSE  the case is in the data the model
#                         was updated on: the share of cases like it (pi-hat).
#   using = "posteriors", case_level = TRUE   the case is NOT in that data: its
#                         evidence also updates the population (phi-hat).
# Never update on a case and then ask a case_level = TRUE question of it.

library(CausalQueries)

qs_cond <- function(values) {
  values <- values[!is.na(unlist(values))]
  if (!length(values)) return("TRUE")
  paste0(names(values), "==", unlist(values), collapse = " & ")
}

qs_case_q <- function(model, query, values, using, case_level) {
  r <- query_model(model, queries = list(q = query), given = list(qs_cond(values)),
                   using = using, case_level = case_level, expand_grid = TRUE)
  as.data.frame(r)$mean[1]
}

# model:  the causal model (untrained, or updated; see above).
# query:  e.g. "Y[X=1] > Y[X=0]".
# known:  values observed before any process tracing, e.g. list(X = 1, Y = 1).
# clues:  the clues found, in the order sought, e.g. list(M = 1, P = 0).
qs_trace_case <- function(model, query, known, clues, using = "parameters",
                          case_level = FALSE) {
  path <- data.frame(step = 0, clue = "(none)", value = NA,
                     posterior = qs_case_q(model, query, known, using, case_level))
  seen <- known
  for (k in names(clues)) {
    seen[[k]] <- clues[[k]]
    path <- rbind(path, data.frame(step = nrow(path), clue = k, value = clues[[k]],
                                   posterior = qs_case_q(model, query, seen, using, case_level)))
  }
  final <- path$posterior[nrow(path)]
  cf <- do.call(rbind, lapply(names(clues), function(k) {
    alt <- c(known, clues); alt[[k]] <- 1 - clues[[k]]
    p_alt <- tryCatch(qs_case_q(model, query, alt, using, case_level), error = function(e) NA)
    data.frame(clue = k, found = clues[[k]], posterior_as_found = final,
               if_other_value = p_alt,
               note = if (is.na(p_alt) || is.nan(p_alt)) "the other value is impossible under the model" else "")
  }))
  list(path = path, counterfactual = cf)
}

# prior:  Pr(H) before the case evidence, from background knowledge stated in
#         a sentence.
# items:  data.frame(id, p_h, p_not) with Pr(E | H) and Pr(E | not H) for each
#         evidence item, in the order fixed before reading; optional columns
#         p_h_low, p_h_high, p_not_low, p_not_high give ranges. Items that share
#         an origin must already be combined into one row.
qs_informal_trace <- function(prior, items) {
  lr <- items$p_h / items$p_not
  lo <- function(p) log(p / (1 - p))
  inv <- function(x) 1 / (1 + exp(-x))
  run <- inv(lo(prior) + cumsum(log(lr)))
  out <- data.frame(id = items$id, p_h = items$p_h, p_not = items$p_not, lr = lr,
                    weight_db = 10 * log10(lr), posterior = run)
  if (all(c("p_h_low", "p_h_high", "p_not_low", "p_not_high") %in% names(items))) {
    lr_min <- items$p_h_low / items$p_not_high       # least favorable to H
    lr_max <- items$p_h_high / items$p_not_low       # most favorable to H
    out$posterior_low <- inv(lo(prior) + cumsum(log(lr_min)))
    out$posterior_high <- inv(lo(prior) + cumsum(log(lr_max)))
  }
  out
}
