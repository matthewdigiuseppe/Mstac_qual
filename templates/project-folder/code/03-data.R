# 03-data.R — assemble the analysis data: cross-case data from data/raw/ joined to the
# coded within-case evidence in data/case-data.csv. One row per case, one column per
# model node, values 0 / 1 / NA (NA = not observed).
# Inputs:  data/raw/..., data/case-data.csv
# Outputs: data/clean/analysis-data.csv

library(here)

# /qualstack:analyze writes here.
