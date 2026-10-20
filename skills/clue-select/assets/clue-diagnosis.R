# clue-diagnosis.R — which clues can move the query, and by how much.
# Bundled with QualStack (/qualstack:clue-select). Copy to code/clue-diagnosis.R
# and source() it from code/02-design.R. Base R plus CausalQueries.
#
#   qs_clue_screen()  structural screen: is a clue d-connected to the query's
#                     theta nodes, given what is observed? (Humphreys & Jacobs
#                     2023, Proposition 1). FALSE means no prior could make it
#                     informative; TRUE means it *may* be.
#   qs_clue_table()   numeric diagnosis under the model's beliefs: the prior on
#                     the query, the chance of finding each clue, the posterior
#                     either way, the likelihoods (phi1, phi0), probative value
#                     if found and if absent, the implied test type, and the
#                     expected learning (1 - expected posterior variance / prior variance).
#   qs_strategy_table() the same for sets of clues observed together.
#   qs_two_step()       dynamic strategies: a first clue, then a second clue (or
#                       none) depending on what the first showed, with expected
#                       variance, expected number of clues and expected cost,
#                       and the undominated cost-variance frontier
#                       (Humphreys & Jacobs 2023, sec. 12.2).
#
# using = "parameters" (default) evaluates at the stored parameters: exact for
# an untrained model whose parameters were set to the prior means
# (set_parameters(model, param_type = "prior_mean")). For a model updated on
# cross-case data, use using = "posteriors": answers are then for a new case
# not in the training data (case_level = TRUE).

library(CausalQueries)

# ---- structural screen ----------------------------------------------------------

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

# query_nodes: the nodes whose types the query is about, e.g. "Y" for
# "Y[X=1] > Y[X=0]" in X -> Y, or c("M", "Y") for X -> M -> Y.
qs_clue_screen <- function(model, query_nodes, clues,
                           observed = list(none = character(0))) {
  edges <- qs_graph(model)
  thetas <- paste0("theta_", query_nodes)
  out <- expand.grid(clue = clues, observed = names(observed), stringsAsFactors = FALSE)
  out$d_connected <- mapply(function(k, w) {
    qs_dconnected(edges, from = k, to = thetas, given = setdiff(observed[[w]], k))
  }, out$clue, out$observed)
  out
}

# ---- numeric diagnosis -------------------------------------------------------------

qs_q <- function(model, query, given, using) {
  r <- query_model(model, queries = list(q = query), given = list(given), using = using,
                   case_level = (using != "parameters"), expand_grid = TRUE)
  as.data.frame(r)$mean[1]
}

# Van Evera's tests as regions of (phi1, phi0) space, with boundaries where the
# likelihood ratios reach 2 (Humphreys & Jacobs 2023, sec. 5.2.1). When finding
# the clue counts *against* the query (phi1 < phi0), the test is stated for its
# absence: "smoking gun (if absent)".
qs_test_type <- function(phi1, phi0) {
  label <- function(f1, f0) {
    sg <- if (f0 > 0) f1 / f0 >= 2 else f1 > 0
    hoop <- if (f1 < 1) (1 - f0) / (1 - f1) >= 2 else f0 < 1
    if (sg && hoop) "doubly decisive" else if (sg) "smoking gun" else if (hoop) "hoop" else "straw in the wind"
  }
  if (isTRUE(all.equal(phi1, phi0))) return("uninformative")
  if (phi1 >= phi0) label(phi1, phi0) else paste(label(1 - phi1, 1 - phi0), "(if absent)")
}

# One row per clue: how observing it would move `query` in a case matching `given`.
qs_clue_table <- function(model, query, given, clues, using = "parameters") {
  q <- qs_q(model, query, given, using)
  rows <- lapply(clues, function(k) {
    p1 <- qs_q(model, paste0(k, "==1"), given, using)          # chance the clue is found (K = 1)
    q1 <- if (p1 > 0) qs_q(model, query, paste0(given, " & ", k, "==1"), using) else NA
    q0 <- if (p1 < 1) qs_q(model, query, paste0(given, " & ", k, "==0"), using) else NA
    phi1 <- if (q > 0 && !is.na(q1)) round(q1 * p1 / q, 10) else NA              # Pr(K=1 | query true)
    phi0 <- if (q < 1 && !is.na(q1)) round((1 - q1) * p1 / (1 - q), 10) else NA  # Pr(K=1 | query false)
    epv <- sum(c(p1 * q1 * (1 - q1), (1 - p1) * q0 * (1 - q0)), na.rm = TRUE)
    data.frame(
      clue = k, prior = q, p_found = p1, post_if_1 = q1, post_if_0 = q0,
      phi1 = phi1, phi0 = phi0,
      pv_if_1 = log10(phi1 / phi0), pv_if_0 = log10((1 - phi0) / (1 - phi1)),
      test = if (is.na(phi1) || is.na(phi0)) NA else qs_test_type(phi1, phi0),
      exp_post_var = epv,
      exp_learning = if (q > 0 && q < 1) 1 - epv / (q * (1 - q)) else 0
    )
  })
  do.call(rbind, rows)
}

# Expected learning from observing a whole set of clues together.
# strategies: a named list, e.g. list(M_only = "M", P_only = "P", both = c("M", "P")).
qs_strategy_table <- function(model, query, given, strategies, using = "parameters") {
  q <- qs_q(model, query, given, using)
  rows <- lapply(names(strategies), function(s) {
    ks <- strategies[[s]]
    grid <- expand.grid(rep(list(0:1), length(ks)))
    epv <- 0
    for (i in seq_len(nrow(grid))) {
      found <- paste0(ks, "==", unlist(grid[i, ]), collapse = " & ")
      p <- qs_q(model, found, given, using)                      # chance of this pattern
      if (p > 0) {
        qk <- qs_q(model, query, paste0(given, " & ", found), using)
        epv <- epv + p * qk * (1 - qk)
      }
    }
    data.frame(strategy = s, clues = paste(ks, collapse = " + "), prior = q,
               exp_post_var = epv,
               exp_learning = if (q > 0 && q < 1) 1 - epv / (q * (1 - q)) else 0)
  })
  do.call(rbind, rows)
}

# Two-step strategies: look for `first`; if it shows 0, look for `if_0` (NA =
# stop); if 1, look for `if_1`. prices: a named vector, e.g. c(M = 1, P = 1.5).
# Labels follow the book: "(P),(M,.)" = observe P; if P=0 observe M; if P=1 stop.
# frontier = TRUE marks strategies no other strategy beats on both expected
# variance and expected cost.
qs_two_step <- function(model, query, given, clues, prices = NULL, using = "parameters") {
  if (is.null(prices)) prices <- setNames(rep(1, length(clues)), clues)
  q <- qs_q(model, query, given, using)
  branch_var <- function(g, k) {                # expected variance at the end of a branch
    qg <- qs_q(model, query, g, using)
    if (is.na(k)) return(qg * (1 - qg))
    pk <- qs_q(model, paste0(k, "==1"), g, using)
    v <- 0
    for (val in 0:1) {
      pv <- if (val == 1) pk else 1 - pk
      if (pv > 0) {
        qv <- qs_q(model, query, paste0(g, " & ", k, "==", val), using)
        v <- v + pv * qv * (1 - qv)
      }
    }
    v
  }
  rows <- list(data.frame(strategy = "priors", first = NA, if_0 = NA, if_1 = NA,
                          exp_n = 0, exp_var = q * (1 - q), exp_cost = 0))
  for (k1 in clues) {
    p1 <- qs_q(model, paste0(k1, "==1"), given, using)
    nexts <- c(NA, setdiff(clues, k1))
    for (k0 in nexts) for (k1b in nexts) {
      ps <- c(1 - p1, p1); seconds <- c(k0, k1b)
      v <- 0; n <- 1; cost <- prices[[k1]]
      for (j in 1:2) if (ps[j] > 0) {
        v <- v + ps[j] * branch_var(paste0(given, " & ", k1, "==", j - 1), seconds[j])
        if (!is.na(seconds[j])) { n <- n + ps[j]; cost <- cost + ps[j] * prices[[seconds[j]]] }
      }
      lab <- paste0("(", k1, "),(", ifelse(is.na(k0), ".", k0), ",", ifelse(is.na(k1b), ".", k1b), ")")
      rows[[length(rows) + 1]] <- data.frame(strategy = lab, first = k1, if_0 = k0, if_1 = k1b,
                                             exp_n = n, exp_var = v, exp_cost = cost)
    }
  }
  out <- do.call(rbind, rows)
  ev <- round(out$exp_var, 9); ec <- round(out$exp_cost, 9)
  out$frontier <- sapply(seq_len(nrow(out)), function(i)
    !any((ev <= ev[i] & ec < ec[i]) | (ev < ev[i] & ec <= ec[i])))
  out$exp_learning <- if (q > 0 && q < 1) 1 - out$exp_var / (q * (1 - q)) else 0
  out[order(out$exp_cost, out$exp_var), ]
}
