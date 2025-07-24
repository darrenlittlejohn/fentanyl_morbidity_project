# ============================================================
# SCRIPT: Master Data Pipeline for Fentanyl Analysis
# PURPOSE:
#   1. Execute all steps: loading, cleaning, and merging datasets.
#   2. Produce final national and state-level analysis DataFrames.
#   3. Ensure reproducibility with consistent file paths and outputs.
# INPUT:
#   - VSRR_Provisional_Drug_Overdose_Death_Counts_20250722.csv
#   - MUP_DPR_RY25_P04_V10_DY23_NPIBN.csv
#   - Multiple Cause of Death, 2018-2023, Single Race.txt
# OUTPUT:
#   - fentanyl_deaths_cleaned.csv
#   - prescriptions_2023_cleaned.csv
#   - senior_fentanyl_cleaned.csv
#   - analysis_df_national.csv
#   - state_analysis_df.csv
#   - state_analysis_df_seniors.csv
# ============================================================

# ------------------------
# 1. Load Required Libraries
# ------------------------
library(readr)
library(dplyr)
library(stringr)
library(janitor)

# ------------------------
# 2. Set Paths
# ------------------------
raw_path <- "C:/Users/Darren/Dev/fentanyl/data/raw/"
clean_path <- "C:/Users/Darren/Dev/fentanyl/data/clean/"

# Create clean directory if missing
dir.create(clean_path, recursive = TRUE, showWarnings = FALSE)

# ------------------------
# 3. Source Scripts
# ------------------------
# These scripts perform dataset loading and cleaning.

source("C:/Users/Darren/Dev/fentanyl/scripts/load_02_mortality_data.R")
source("C:/Users/Darren/Dev/fentanyl/scripts/load_02_prescriber_data.R")
source("C:/Users/Darren/Dev/fentanyl/scripts/merge_02_data_for_analysis.R")

# ------------------------
# 4. Verification Steps
# ------------------------
cat("\n==== Verification of Outputs ====\n")

# National-level summary
if (exists("analysis_df_national")) {
  print(analysis_df_national)
} else {
  cat("analysis_df_national not found.\n")
}

# State-level summary
if (exists("state_analysis_df")) {
  print(head(state_analysis_df, 10))
} else {
  cat("state_analysis_df not found.\n")
}

# Seniors-level summary
if (exists("state_analysis_df_seniors")) {
  print(head(state_analysis_df_seniors, 10))
} else {
  cat("state_analysis_df_seniors not found.\n")
}

# ------------------------
# 5. Completion Message
# ------------------------
cat("\nPipeline complete. Clean datasets and merged analysis files are ready in:\n", clean_path, "\n")
