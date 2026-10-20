# 04-update.R — update the model on the data and answer every query, prior next to posterior.
# Inputs:  output/models/model.rds, data/clean/analysis-data.csv
# Outputs: output/models/model-updated.rds, output/tables/queries.csv, output/tables/queries.tex

library(CausalQueries)
library(here)

# /qualstack:analyze writes here.
