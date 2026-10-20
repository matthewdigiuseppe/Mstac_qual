# 01-model.R — the causal model: DAG, restrictions, confounding, priors.
# Package: CausalQueries (Humphreys & Jacobs's companion to Integrated Inferences).
# Inputs:  none (the model is declared, not estimated)
# Outputs: output/models/model.rds, output/tables/nodal-types.csv, output/tables/prior-queries.csv

library(CausalQueries)
library(here)

# /qualstack:causal-model writes here.
