library(readr)
library(dplyr)
library(stringr)
library(janitor)

# Correct file path from screenshot
prescriptions_file <- "C:/Users/Darren/Dev/fentanyl/data/raw/medicare_prescribers_by_provider_drug/prescribers_by_provider_drug/MUP_DPR_RY25_P04_V10_DY23_NPIBN.csv"

# Load prescription data
prescriptions_2023 <- read_csv(prescriptions_file)

# Inspect structure
glimpse(prescriptions_2023)

### CLEAN PRESCRIPTION DATASET

library(readr)
library(dplyr)
library(stringr)
library(janitor)
library(tidyr)

# Load prescription dataset
prescriptions_file <- "C:/Users/Darren/Dev/fentanyl/data/raw/medicare_prescribers_by_provider_drug/prescribers_by_provider_drug/MUP_DPR_RY25_P04_V10_DY23_NPIBN.csv"
prescriptions_2023 <- read_csv(prescriptions_file)

# Clean dataset
prescriptions_2023_cleaned <- prescriptions_2023 %>%
  janitor::clean_names() %>%
  mutate(across(where(is.character), ~str_squish(.))) %>%
  mutate(across(where(is.character), ~na_if(., ""))) %>%
  mutate(
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
  distinct()

# Save cleaned dataset
write_csv(prescriptions_2023_cleaned, "C:/Users/Darren/Dev/fentanyl/data/clean/prescriptions_2023_cleaned.csv")

# Verify cleaning of prescriptions_2023_cleaned

# 1. Check structure and column names
glimpse(prescriptions_2023_cleaned)
colnames(prescriptions_2023_cleaned)

# 2. Check unique states
unique(prescriptions_2023_cleaned$prscrbr_state_abrvtn)
prescriptions_2023_cleaned <- prescriptions_2023_cleaned %>%
  filter(prscrbr_state_abrvtn %in% state.abb)


# 3. Check for missing values
sapply(prescriptions_2023_cleaned, function(x) sum(is.na(x)))

# 4. Summary statistics for numeric columns
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

# 5. Check for duplicates
sum(duplicated(prescriptions_2023_cleaned))

# Create the clean directory if it doesn't exist
dir.create("C:/Users/Darren/Dev/fentanyl/data/clean", recursive = TRUE, showWarnings = FALSE)

# Save cleaned dataset
write_csv(prescriptions_2023_cleaned, "C:/Users/Darren/Dev/fentanyl/data/clean/prescriptions_2023_cleaned.csv")

# VERIFY CLEANING OF prescriptions_2023_cleaned

# 1. Check structure and column names
glimpse(prescriptions_2023_cleaned)
colnames(prescriptions_2023_cleaned)

# 2. Check unique states
unique(prescriptions_2023_cleaned$prscrbr_state_abrvtn)

# 3. Check for missing values
sapply(prescriptions_2023_cleaned, function(x) sum(is.na(x)))

# 4. Summary statistics for numeric columns
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

# 5. Check for duplicates
sum(duplicated(prescriptions_2023_cleaned))

# FINAL VERIFICATION OUTPUT
list(
  structure = glimpse(prescriptions_2023_cleaned),
  column_names = colnames(prescriptions_2023_cleaned),
  missing_values = sapply(prescriptions_2023_cleaned, function(x) sum(is.na(x))),
  numeric_summary = prescriptions_2023_cleaned %>%
    summarise(
      total_rows = n(),
      total_claims = sum(tot_clms, na.rm = TRUE),
      min_claims = min(tot_clms, na.rm = TRUE),
      max_claims = max(tot_clms, na.rm = TRUE),
      total_drug_cost = sum(tot_drug_cst, na.rm = TRUE),
      min_drug_cost = min(tot_drug_cst, na.rm = TRUE),
      max_drug_cost = max(tot_drug_cst, na.rm = TRUE)
    ),
  duplicate_count = sum(duplicated(prescriptions_2023_cleaned))
)

###
library(readr)
library(dplyr)
library(stringr)
library(janitor)
library(tidyr)

# Ensure column names are cleaned before filtering
prescriptions_2023_clean_temp <- prescriptions_2023 %>%
  janitor::clean_names()

# Extract fentanyl-related prescriptions
fentanyl_raw <- prescriptions_2023_clean_temp %>%
  filter(str_detect(gnrc_name, regex("fentanyl", ignore_case = TRUE)))

# Clean extracted dataset
fentanyl_prescriptions_cleaned <- fentanyl_raw %>%
  mutate(across(where(is.character), ~str_squish(.))) %>%
  mutate(across(where(is.character), ~na_if(., ""))) %>%
  mutate(
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
  distinct()

# Verify cleaning
glimpse(fentanyl_prescriptions_cleaned)
colnames(fentanyl_prescriptions_cleaned)
sapply(fentanyl_prescriptions_cleaned, function(x) sum(is.na(x)))
fentanyl_prescriptions_cleaned %>%
  summarise(
    total_rows = n(),
    total_claims = sum(tot_clms, na.rm = TRUE),
    min_claims = min(tot_clms, na.rm = TRUE),
    max_claims = max(tot_clms, na.rm = TRUE),
    total_drug_cost = sum(tot_drug_cst, na.rm = TRUE),
    min_drug_cost = min(tot_drug_cst, na.rm = TRUE),
    max_drug_cost = max(tot_drug_cst, na.rm = TRUE)
  )
sum(duplicated(fentanyl_prescriptions_cleaned))

# Save cleaned fentanyl prescriptions dataset
dir.create("C:/Users/Darren/Dev/fentanyl/data/clean", recursive = TRUE, showWarnings = FALSE)
write_csv(fentanyl_prescriptions_cleaned, "C:/Users/Darren/Dev/fentanyl/data/clean/fentanyl_prescriptions_cleaned.csv")


