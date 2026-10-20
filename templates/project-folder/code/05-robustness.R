# 05-robustness.R — sensitivity of the answers to the model: priors, restrictions,
# confounding, clue measurement error, single cases, single sources.
# Inputs:  output/models/model.rds, data/clean/analysis-data.csv
# Outputs: output/models/robustness.rds, output/tables/robustness.csv

library(CausalQueries)
library(here)

# /qualstack:robustness writes here.
