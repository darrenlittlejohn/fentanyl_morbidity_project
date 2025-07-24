# SCRIPT: Load and Clean Medicare Prescription Data (2023)
# PURPOSE:
#   1. Load raw Medicare prescription data.
#   2. Clean and standardize column names and data types.
#   3. Filter for fentanyl-related prescriptions.
#   4. Save cleaned datasets for analysis.
# INPUT:
#   - MUP_DPR_RY25_P04_V10_DY23_NPIBN.csv
# OUTPUT:
#   - prescriptions_2023_cleaned.csv
#   - fentanyl_prescriptions_cleaned.csv
# ============================================================

# ------------------------
# 1. Load Required Libraries
# ------------------------
library(readr)      # For reading CSV files
library(dplyr)      # For data manipulation
library(stringr)    # For string matching and cleaning
library(janitor)    # For cleaning column names
library(tidyr)      # For handling NA values

# ------------------------
# 2. Load Raw Prescription Data
# ------------------------
prescriptions_file <- "C:/Users/Darren/Dev/fentanyl/data/raw/medicare_prescribers_by_provider_drug/prescribers_by_provider_drug/MUP_DPR_RY25_P04_V10_DY23_NPIBN.csv"
prescriptions_2023 <- read_csv(prescriptions_file)

# Inspect structure
glimpse(prescriptions_2023)

# ------------------------
# 3. Clean Prescription Dataset
# ------------------------
prescriptions_2023_cleaned <- prescriptions_2023 %>%
  janitor::clean_names() %>%                         # Standardize column names
  mutate(across(where(is.character), ~ str_squish(.))) %>% 
  mutate(across(where(is.character), ~ na_if(., ""))) %>%
  mutate(                                             # Convert numeric fields
    tot_clms = as.numeric(tot_clms),
    tot_30day_fills = as.numeric(tot_30day_fills),
    tot_day_suply = as.numeric(tot_day_suply),
    tot_drug_cst = as.numeric(tot_drug_cst),
    tot_benes = as.numeric(tot_benes),
    ge65_tot_clms = as.numeric(ge65_tot_clms),
    ge65_tot_30day_fills = as.numeric(ge65_tot_30day_fills),
    ge65_tot_drug_cst = as.numeric(ge65_tot_drug_cst),
    ge65_tot_day_suply = as.numeric(ge65_tot_day_suply),
    ge65_tot_benes = as.numeric(ge65_tot_benes)
  ) %>%
  filter(prscrbr_state_abrvtn %in% state.abb) %>%     # Keep valid state codes
  distinct()                                          # Remove duplicate rows

# Ensure clean directory exists
dir.create("C:/Users/Darren/Dev/fentanyl/data/clean", recursive = TRUE, showWarnings = FALSE)

# Save cleaned dataset
write_csv(prescriptions_2023_cleaned, "C:/Users/Darren/Dev/fentanyl/data/clean/prescriptions_2023_cleaned.csv")

# ------------------------
# 4. Verify Cleaned Dataset
# ------------------------
# Structure and columns
glimpse(prescriptions_2023_cleaned)
colnames(prescriptions_2023_cleaned)

# Missing values
sapply(prescriptions_2023_cleaned, function(x) sum(is.na(x)))

# Summary statistics
prescriptions_2023_cleaned %>%
  summarise(
    total_rows = n(),
    total_claims = sum(tot_clms, na.rm = TRUE),
    min_claims = min(tot_clms, na.rm = TRUE),
    max_claims = max(tot_clms, na.rm = TRUE),
    total_drug_cost = sum(tot_drug_cst, na.rm = TRUE),
    min_drug_cost = min(tot_drug_cst, na.rm = TRUE),
    max_drug_cost = max(tot_drug_cst, na.rm = TRUE)
  )

# Duplicate count
sum(duplicated(prescriptions_2023_cleaned))

# ------------------------
# 5. Extract and Clean Fentanyl Prescriptions
# ------------------------
fentanyl_prescriptions_cleaned <- prescriptions_2023_cleaned %>%
  filter(str_detect(gnrc_name, regex("fentanyl", ignore_case = TRUE))) %>%
  mutate(across(where(is.character), ~ str_squish(.))) %>%
  mutate(across(where(is.character), ~ na_if(., ""))) %>%
  distinct()

# Verify fentanyl subset
glimpse(fentanyl_prescriptions_cleaned)
sapply(fentanyl_prescriptions_cleaned, function(x) sum(is.na(x)))

# Save fentanyl-specific dataset
write_csv(fentanyl_prescriptions_cleaned, "C:/Users/Darren/Dev/fentanyl/data/clean/fentanyl_prescriptions_cleaned.csv")

# ------------------------
# 6. Final Verification Output
# ------------------------
list(
  structure = glimpse(prescriptions_2023_cleaned),
  column_names = colnames(prescriptions_2023_cleaned),
  missing_values = sapply(prescriptions_2023_cleaned, function(x) sum(is.na(x))),
  fentanyl_rows = nrow(fentanyl_prescriptions_cleaned),
  duplicate_count = sum(duplicated(prescriptions_2023_cleaned))
)
