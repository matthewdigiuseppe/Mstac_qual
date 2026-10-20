# 03-data.R — assemble the analysis data: one row per case, one column per model
# node, values 0 / 1 / NA (NA = not observed).
# Written by /qualstack:analyze from QualStack's template.
# Inputs:  output/models/model.rds, data/case-data.csv (coded within-case evidence),
#          data/raw/... (cross-case data, optional)
# Outputs: data/clean/analysis-data.csv

library(here)

model <- readRDS(here("output", "models", "model.rds"))
nodes <- as.character(CausalQueries::grab(model, "nodes"))

coded <- read.csv(here("data", "case-data.csv"), stringsAsFactors = FALSE, check.names = FALSE)

# ---- Cross-case data (optional) -------------------------------------------------
# Dichotomize by the rule in data/coding-rules.md (state the cut there, not here
# only), keep `case` plus model nodes, and never edit data/raw/ in place, e.g.:
# raw <- read.csv(here("data", "raw", "countries.csv"))
# cross <- data.frame(case = raw$country,
#                     X = as.integer(raw$gini >= 0.40),        # rule X v1
#                     Y = as.integer(raw$democracy_2000 == 1)) # rule Y v1
cross <- NULL

# ---- Join -----------------------------------------------------------------------------
if (is.null(cross)) {
  data <- coded
} else {
  data <- merge(cross, coded, by = "case", all = TRUE, suffixes = c(".cross", ".coded"))
  for (v in nodes) {
    a <- paste0(v, ".cross"); b <- paste0(v, ".coded")
    if (all(c(a, b) %in% names(data))) {
      clash <- !is.na(data[[a]]) & !is.na(data[[b]]) & data[[a]] != data[[b]]
      if (any(clash)) stop("dataset and case coding disagree on ", v, " for: ",
                           paste(data$case[clash], collapse = ", "),
                           " (resolve in data/coding-log.csv, then re-run)")
      data[[v]] <- ifelse(is.na(data[[b]]), data[[a]], data[[b]])
      data[[a]] <- NULL; data[[b]] <- NULL
    }
  }
}

# ---- Checks: CausalQueries fails silently otherwise -----------------------------------
# A misspelled column is dropped without warning (the node becomes NA for every
# case); a value other than 0/1/NA drops the whole case with only a message.
stopifnot("every row needs a case name" = all(nzchar(data$case)),
          "case names must be unique" = !anyDuplicated(data$case))
absent <- setdiff(nodes, names(data))
if (length(absent)) stop("no column for model node(s): ", paste(absent, collapse = ", "))
extra <- setdiff(names(data), c("case", nodes))
if (length(extra)) message("columns that are not model nodes (dropped): ", paste(extra, collapse = ", "))
for (v in nodes) {
  bad <- !is.na(data[[v]]) & !(data[[v]] %in% c(0, 1))
  if (any(bad)) stop("node ", v, " has values other than 0/1/NA for: ", paste(data$case[bad], collapse = ", "))
}

analysis <- data[order(data$case), c("case", nodes)]
dir.create(here("data", "clean"), recursive = TRUE, showWarnings = FALSE)
write.csv(analysis, here("data", "clean", "analysis-data.csv"), row.names = FALSE)

# ---- What the update will see -------------------------------------------------------------
cat("Cases:", nrow(analysis), "\nObserved per node:\n")
print(colSums(!is.na(analysis[nodes])))
pattern <- apply(analysis[nodes], 1, function(r) paste0(nodes, "=", ifelse(is.na(r), "?", r), collapse = " "))
cat("\nData patterns (? = not observed):\n")
print(sort(table(pattern), decreasing = TRUE))
