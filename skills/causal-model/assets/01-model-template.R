# 01-model.R — the causal model: DAG, restrictions, confounding, priors.
# Written by /qualstack:causal-model. Every choice below carries a label
# (R1, P1, C1, ...) that .qualstack/model.md justifies; change the two together.
# Inputs:  none (the model is declared, not estimated)
# Outputs: output/models/model.rds            the model every later script loads
#          output/models/queries.rds          the queries and givens, for code/04-update.R
#          output/tables/nodal-types.csv      the nodal types that survive the restrictions
#          output/tables/prior-queries.csv    what the model believes before any case evidence

library(CausalQueries)
library(here)

SEED <- 20250101  # model.seed in .qualstack/config.yaml
set.seed(SEED)

# ---- 1. The DAG -------------------------------------------------------------
# Every absent arrow is a claim that a direct effect is impossible (model.md, "Arrows").
# Unobserved confounding is declared here with "<->", e.g. "X -> Y; X <-> Y" (C1).
STATEMENT <- "X -> M -> Y <- X"
model <- make_model(STATEMENT)

# ---- 2. Restrictions: nodal types ruled out ----------------------------------
# set_restrictions() REMOVES the types for which the statement is TRUE.
model <- set_restrictions(model, decreasing("X", "M"))  # R1: X never lowers M
model <- set_restrictions(model, decreasing("M", "Y"))  # R2: M never lowers Y

# ---- 3. Priors over the types that remain ----------------------------------------
# Flat Dirichlet (alpha = 1) unless model.md justifies a departure, e.g.
# model <- set_priors(model, node = "M", nodal_type = "01", alphas = 2)  # P1
# Single-case answers are exact at the prior means, so store them as parameters:
model <- set_parameters(model, param_type = "prior_mean")

# ---- 4. The queries (copied from .qualstack/queries.md) ----------------------
QUERIES <- list(
  Q1 = "Y[X=1] > Y[X=0]"          # primary: did X cause Y? (with GIVENS below)
)
GIVENS <- list(TRUE, "X==1 & Y==1", "X==1 & Y==0", "X==0 & Y==1", "X==0 & Y==0")

# ---- 5. Report and save ----------------------------------------------------------
dir.create(here("output", "models"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("output", "tables"), recursive = TRUE, showWarnings = FALSE)

nodal <- grab(model, "nodal_types")
n_types <- vapply(nodal, length, integer(1))
cat("Nodal types per node:", paste(names(n_types), n_types, sep = " = ", collapse = ", "), "\n")
cat("Causal types:", nrow(grab(model, "causal_types")), "\n")
# Complexity budget: a node with 4 binary parents has 65,536 nodal types; restrict or simplify.
stopifnot("a node has more than 256 nodal types; see model.md" = all(n_types <= 256))

write.csv(
  data.frame(node = rep(names(nodal), n_types), nodal_type = unlist(nodal, use.names = FALSE)),
  here("output", "tables", "nodal-types.csv"), row.names = FALSE
)

# expand_grid = TRUE crosses every query with every given; without it the
# arguments are paired, and the printed table can hide rows.
prior_q <- query_model(model, queries = QUERIES, given = GIVENS,
                       using = "parameters", expand_grid = TRUE)
prior_q <- as.data.frame(prior_q)
write.csv(prior_q, here("output", "tables", "prior-queries.csv"), row.names = FALSE)
print(prior_q[, intersect(c("label", "given", "mean"), names(prior_q))], row.names = FALSE)

saveRDS(model, here("output", "models", "model.rds"))
# code/04-update.R asks the same questions of the updated model.
saveRDS(list(queries = QUERIES, givens = GIVENS), here("output", "models", "queries.rds"))
writeLines(capture.output(sessionInfo()), here("output", "session-info.txt"))
cat("Saved output/models/model.rds\n")
