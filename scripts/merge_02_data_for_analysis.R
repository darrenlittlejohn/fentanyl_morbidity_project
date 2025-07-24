# ============================================================
# SCRIPT: Merge Data for Analysis
# PURPOSE:
#   1. Load cleaned mortality, senior mortality, and prescription datasets.
#   2. Merge datasets into unified state-level and national-level DataFrames.
#   3. Ensure consistency across state codes and names.
#   4. Save merged DataFrames for analysis and visualization.
# INPUT:
#   - fentanyl_deaths_cleaned.csv
#   - prescriptions_2023_cleaned.csv
#   - senior_fentanyl_cleaned.csv (65+ data)
# OUTPUT:
#   - analysis_df_national.csv
#   - state_analysis_df.csv
#   - state_analysis_df_seniors.csv
# ============================================================

# ------------------------
# 1. Load Required Libraries
# ------------------------
library(readr)      # For reading/writing CSV files
library(dplyr)      # For data manipulation
library(janitor)    # For cleaning column names
library(stringr)    # For string matching and filtering

# ------------------------
# 2. Load Cleaned Datasets
# ------------------------
fentanyl_deaths_cleaned <- read_csv("C:/Users/Darren/Dev/fentanyl/data/clean/fentanyl_deaths_cleaned.csv")
prescriptions_2023_cleaned <- read_csv("C:/Users/Darren/Dev/fentanyl/data/clean/prescriptions_2023_cleaned.csv")
senior_fentanyl_cleaned <- read_csv("C:/Users/Darren/Dev/fentanyl/data/clean/senior_fentanyl_cleaned.csv")

# Verify structure
glimpse(fentanyl_deaths_cleaned)
glimpse(prescriptions_2023_cleaned)
glimpse(senior_fentanyl_cleaned)

# ------------------------
# 3. Build National-Level DataFrame
# ------------------------
# Aggregate national totals for 2023
deaths_national_2023 <- fentanyl_deaths_cleaned %>%
  filter(year == 2023) %>%
  summarise(total_deaths = sum(data_value, na.rm = TRUE))

prescriptions_national_2023 <- prescriptions_2023_cleaned %>%
  summarise(total_prescriptions = sum(tot_clms, na.rm = TRUE))

fentanyl_prescriptions_national <- prescriptions_2023_cleaned %>%
  filter(str_detect(gnrc_name, regex("fentanyl", ignore_case = TRUE))) %>%
  summarise(
    fentanyl_prescriptions = sum(tot_clms, na.rm = TRUE),
    fentanyl_cost = sum(tot_drug_cst, na.rm = TRUE)
  )

analysis_df_national <- data.frame(
  year = 2023,
  total_prescriptions = prescriptions_national_2023$total_prescriptions,
  fentanyl_prescriptions = fentanyl_prescriptions_national$fentanyl_prescriptions,
  fentanyl_cost = fentanyl_prescriptions_national$fentanyl_cost,
  total_deaths = deaths_national_2023$total_deaths
)

write_csv(analysis_df_national, "C:/Users/Darren/Dev/fentanyl/data/clean/analysis_df_national.csv")

# ------------------------
# 4. Build State-Level DataFrame
# ------------------------
state_deaths_2023 <- fentanyl_deaths_cleaned %>%
  filter(year == 2023) %>%
  group_by(state) %>%
  summarise(total_deaths = sum(data_value, na.rm = TRUE)) %>%
  ungroup()

state_prescriptions_2023 <- prescriptions_2023_cleaned %>%
  group_by(prscrbr_state_abrvtn) %>%
  summarise(total_prescriptions = sum(tot_clms, na.rm = TRUE)) %>%
  rename(state = prscrbr_state_abrvtn)

state_fentanyl_prescriptions_2023 <- prescriptions_2023_cleaned %>%
  filter(str_detect(gnrc_name, regex("fentanyl", ignore_case = TRUE))) %>%
  group_by(prscrbr_state_abrvtn) %>%
  summarise(
    fentanyl_prescriptions = sum(tot_clms, na.rm = TRUE),
    fentanyl_cost = sum(tot_drug_cst, na.rm = TRUE)
  ) %>%
  rename(state = prscrbr_state_abrvtn)

state_analysis_df <- state_prescriptions_2023 %>%
  left_join(state_fentanyl_prescriptions_2023, by = "state") %>%
  left_join(state_deaths_2023, by = "state")

write_csv(state_analysis_df, "C:/Users/Darren/Dev/fentanyl/data/clean/state_analysis_df.csv")

# ------------------------
# 5. Merge Senior Data
# ------------------------
# Merge 65+ mortality data into state-level DataFrame
state_analysis_df_seniors <- state_analysis_df %>%
  left_join(
    senior_fentanyl_cleaned %>%
      select(state_name, total_deaths_65plus) %>%
      rename(state = state_name),
    by = "state"
  )

# Calculate ratios
state_analysis_df_seniors <- state_analysis_df_seniors %>%
  mutate(
    prescriptions_per_death_65plus = ifelse(total_deaths_65plus > 0,
                                            total_prescriptions / total_deaths_65plus, NA),
    fentanyl_prescriptions_per_death_65plus = ifelse(total_deaths_65plus > 0,
                                                     fentanyl_prescriptions / total_deaths_65plus, NA)
  )

write_csv(state_analysis_df_seniors, "C:/Users/Darren/Dev/fentanyl/data/clean/state_analysis_df_seniors.csv")

# ------------------------
# 6. Verification
# ------------------------
glimpse(analysis_df_national)
glimpse(state_analysis_df)
glimpse(state_analysis_df_seniors)
