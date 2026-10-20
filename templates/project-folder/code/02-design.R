# 02-design.R — design diagnosis: which clues to seek, which cases to trace,
# how to split effort between more cases and more within-case evidence.
# Inputs:  output/models/model.rds, data/clean/analysis-data.csv (if cross-case data exist)
# Outputs: output/tables/clue-diagnosis.csv, output/tables/case-diagnosis.csv

library(CausalQueries)
library(here)

# /qualstack:clue-select, /qualstack:case-select, and /qualstack:design-research write here.
