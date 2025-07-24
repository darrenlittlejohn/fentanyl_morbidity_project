# ============================================================
# SCRIPT: BUILD__02__DATAFRAMES.R
# PURPOSE:
#   1. Build all data frames for analysis (national, state, and senior).
#   2. Use already cleaned datasets (mortality, prescriptions, senior deaths).
#   3. Produce final merged and aggregated data frames ready for analysis.
# INPUT:
#   - fentanyl_deaths_cleaned.csv
#   - prescriptions_2023_cleaned.csv
#   - senior_fentanyl_cleaned.csv
# OUTPUT:
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
clean_path <- "C:/Users/Darren/Dev/fentanyl/data/clean/"

# ------------------------
# 3. Load Cleaned Data
# ------------------------
fentanyl_deaths_cleaned <- read_csv(file.path(clean_path, "fentanyl_deaths_cleaned.csv"))
prescriptions_2023_cleaned <- read_csv(file.path(clean_path, "prescriptions_2023_cleaned.csv"))
senior_fentanyl_cleaned <- read_csv(file.path(clean_path, "senior_fentanyl_cleaned.csv"))

# ------------------------
# 4. National-Level Data Frame
# ------------------------
# Aggregate total prescriptions and fentanyl prescriptions (national)
national_prescriptions <- prescriptions_2023_cleaned %>%
  summarise(
    total_prescriptions = sum(tot_clms, na.rm = TRUE),
    fentanyl_prescriptions = sum(tot_clms[str_detect(gnrc_name, regex("fentanyl", ignore_case = TRUE))], na.rm = TRUE),
    fentanyl_cost = sum(tot_drug_cst[str_detect(gnrc_name, regex("fentanyl", ignore_case = TRUE))], na.rm = TRUE)
  )

# Aggregate total deaths (national)
national_deaths <- fentanyl_deaths_cleaned %>%
  filter(year == 2023) %>%
  summarise(total_deaths = sum(data_value, na.rm = TRUE))

# Build national-level analysis DF
analysis_df_national <- national_prescriptions %>%
  mutate(year = 2023) %>%
  bind_cols(national_deaths)

# Save
write_csv(analysis_df_national, file.path(clean_path, "analysis_df_national.csv"))

# ------------------------
# 5. State-Level Data Frame
# ------------------------
# Prescriptions by state
state_prescriptions <- prescriptions_2023_cleaned %>%
  group_by(prscrbr_state_abrvtn) %>%
  summarise(
    total_prescriptions = sum(tot_clms, na.rm = TRUE),
    fentanyl_prescriptions = sum(tot_clms[str_detect(gnrc_name, regex("fentanyl", ignore_case = TRUE))], na.rm = TRUE),
    fentanyl_cost = sum(tot_drug_cst[str_detect(gnrc_name, regex("fentanyl", ignore_case = TRUE))], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  rename(state = prscrbr_state_abrvtn)

# Deaths by state
state_deaths <- fentanyl_deaths_cleaned %>%
  filter(year == 2023, state %in% state.abb) %>%
  group_by(state) %>%
  summarise(total_deaths = sum(data_value, na.rm = TRUE), .groups = "drop")

# Merge into state_analysis_df
state_analysis_df <- state_prescriptions %>%
  left_join(state_deaths, by = "state")

# Save
write_csv(state_analysis_df, file.path(clean_path, "state_analysis_df.csv"))

# ------------------------
# 6. Senior-Level State Data Frame
# ------------------------
# Senior deaths by state
state_deaths_seniors <- senior_fentanyl_cleaned %>%
  group_by(state_name) %>%
  summarise(total_deaths_65plus = sum(total_deaths_65plus, na.rm = TRUE), .groups = "drop")

# Add state abbreviations to state_analysis_df
state_analysis_df_seniors <- state_analysis_df %>%
  mutate(state_name = state.name[match(state, state.abb)]) %>%
  left_join(state_deaths_seniors, by = "state_name") %>%
  mutate(
    prescriptions_per_death_65plus = ifelse(total_deaths_65plus > 0,
                                            total_prescriptions / total_deaths_65plus, NA),
    fentanyl_prescriptions_per_death_65plus = ifelse(total_deaths_65plus > 0,
                                                     fentanyl_prescriptions / total_deaths_65plus, NA)
  )

# Save
write_csv(state_analysis_df_seniors, file.path(clean_path, "state_analysis_df_seniors.csv"))

# ------------------------
# 7. Verification
# ------------------------
cat("\n==== NATIONAL ====\n")
print(analysis_df_national)

cat("\n==== STATE (first 10) ====\n")
print(head(state_analysis_df, 10))

cat("\n==== SENIORS (first 10) ====\n")
print(head(state_analysis_df_seniors, 10))

cat("\nDataFrames built and saved to:", clean_path, "\n")
