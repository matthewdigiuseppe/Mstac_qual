# 04-update.R — update the model on the data once; answer every query, prior next
# to posterior; record what the data taught the model.
# Written by /qualstack:analyze from QualStack's template.
# Inputs:  output/models/model.rds, output/models/queries.rds, data/clean/analysis-data.csv
# Outputs: output/models/model-updated.rds
#          output/tables/queries.csv, queries.tex     population and subgroup answers
#          output/tables/case-answers.csv             one row per traced case
#          output/tables/parameters.csv               prior vs posterior nodal-type shares
#          output/tables/clue-value.csv               each clue's pull, untrained vs trained
#          output/models/stan-warnings.txt

library(CausalQueries)
library(here)

SEED <- 20250101  # model.seed in .qualstack/config.yaml
ITER <- 4000; CHAINS <- 4   # raise ITER until stan-warnings.txt is empty

model <- readRDS(here("output", "models", "model.rds"))
qs <- readRDS(here("output", "models", "queries.rds"))
data <- read.csv(here("data", "clean", "analysis-data.csv"), stringsAsFactors = FALSE)
nodes <- as.character(grab(model, "nodes"))

# ---- 1. Update once -------------------------------------------------------------------
# Every case stays in, clues NA where not sought: dropping untraced cases changes
# the likelihood. update_model() restarts from the priors on every call.
set.seed(SEED)
updated <- update_model(model, data[, nodes], iter = ITER, chains = CHAINS, refresh = 0)
saveRDS(updated, here("output", "models", "model-updated.rds"))
warn <- updated$stan_objects$stan_warnings
writeLines(if (length(warn) && any(nzchar(warn))) warn else "none",
           here("output", "models", "stan-warnings.txt"))
if (length(warn) && any(nzchar(warn))) message("Stan warnings: raise ITER and re-run\n", paste(warn, collapse = "\n"))

# ---- 2. Population and subgroup queries: prior next to posterior ----------------------
set.seed(SEED)
res <- query_model(updated, queries = qs$queries, given = qs$givens,
                   using = c("priors", "posteriors"), expand_grid = TRUE)
res <- as.data.frame(res)
write.csv(res, here("output", "tables", "queries.csv"), row.names = FALSE)
print(res[, intersect(c("label", "given", "using", "mean", "sd", "cred.low", "cred.high"), names(res))],
      row.names = FALSE, digits = 3)

fmt <- function(x) formatC(x, format = "f", digits = 2)
tex <- c("\\begin{tabular}{llcc}", "\\hline",
         "Query & Given & Prior & Posterior \\\\", "\\hline")
pri <- res[res$using == "priors", ]; pos <- res[res$using == "posteriors", ]
for (i in seq_len(nrow(pos))) {
  j <- which(pri$label == pos$label[i] & pri$given == pos$given[i])[1]
  cell <- function(r) paste0(fmt(r$mean), " [", fmt(r$cred.low), ", ", fmt(r$cred.high), "]")
  tex <- c(tex, paste(pos$label[i], "&", gsub("&", "\\\\&", pos$given[i]), "&",
                      cell(pri[j, ]), "&", cell(pos[i, ]), "\\\\"))
}
tex <- c(tex, "\\hline", "\\end{tabular}")
writeLines(tex, here("output", "tables", "queries.tex"))

# ---- 3. Named cases ---------------------------------------------------------------------
# These cases are in the data the model was updated on, so each answer is the
# share of cases like it among the population (case_level = FALSE, pi-hat);
# asking a case_level = TRUE question of them would use their data twice.
traced <- data[rowSums(is.na(data[, nodes])) < length(nodes), ]
cond <- function(r) {
  v <- unlist(r[nodes]); v <- v[!is.na(v)]
  paste0(names(v), "==", v, collapse = " & ")
}
case_rows <- lapply(seq_len(nrow(traced)), function(i) {
  g <- cond(traced[i, ])
  q <- as.data.frame(query_model(updated, queries = qs$queries[1], given = g,
                                 using = "posteriors", case_level = FALSE))
  data.frame(case = traced$case[i], observed = g, query = q$query, mean = q$mean,
             sd = q$sd, cred.low = q$cred.low, cred.high = q$cred.high)
})
case_answers <- do.call(rbind, case_rows)
write.csv(case_answers, here("output", "tables", "case-answers.csv"), row.names = FALSE)

# ---- 4. What the data taught the model ----------------------------------------------------
# A headline query that barely moves can hide learning about its parts.
pdf_ <- grab(updated, "parameters_df")
grp <- paste(pdf_$param_set, pdf_$given)
prior_mean <- ave(pdf_$priors, grp, FUN = function(a) a / sum(a))
post <- grab(updated, "posterior_distribution")
params <- data.frame(param = pdf_$param_names, node = pdf_$node, nodal_type = pdf_$nodal_type,
                     prior_mean = prior_mean, posterior_mean = colMeans(post)[pdf_$param_names],
                     posterior_sd = apply(post, 2, sd)[pdf_$param_names])
write.csv(params, here("output", "tables", "parameters.csv"), row.names = FALSE)

# ---- 5. Each clue's pull, before and after training (mixed-methods.md) -------------------
# For each case type in CELLS and each clue: the answer with the clue unobserved,
# at 0, and at 1, under the untrained model (prior means) and the trained one.
# theory-derived = moves the untrained answer; data-derived = moves only the
# trained one; contradicted = training removes or reverses the pull.
CLUES <- setdiff(nodes, c("X", "Y"))                  # edit: the process-tracing clues
CELLS <- list("X==1 & Y==1", "X==0 & Y==0")             # edit: the case types traced
PRIMARY <- qs$queries[1]
untrained <- set_parameters(model, param_type = "prior_mean")
pull <- do.call(rbind, lapply(CELLS, function(cl) do.call(rbind, lapply(CLUES, function(k) {
  g <- c(cl, paste0(cl, " & ", k, "==0"), paste0(cl, " & ", k, "==1"))
  a <- as.data.frame(query_model(untrained, PRIMARY, given = as.list(g), using = "parameters", expand_grid = TRUE))$mean
  b <- as.data.frame(query_model(updated, PRIMARY, given = as.list(g), using = "posteriors", expand_grid = TRUE))$mean
  data.frame(cell = cl, clue = k, untrained_none = a[1], untrained_0 = a[2], untrained_1 = a[3],
             trained_none = b[1], trained_0 = b[2], trained_1 = b[3])
}))))
write.csv(pull, here("output", "tables", "clue-value.csv"), row.names = FALSE)
print(pull, digits = 3, row.names = FALSE)

writeLines(capture.output(sessionInfo()), here("output", "models", "session-info-update.txt"))
