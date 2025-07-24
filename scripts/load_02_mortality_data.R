# ============================================================
# SCRIPT: Load and Clean Fentanyl Mortality Data
# PURPOSE:
#   1. Load the raw provisional drug overdose death counts file.
#   2. Filter the data for 2023 only and summarize deaths.
#   3. Clean and prepare the dataset for analysis.
#   4. Save a cleaned version of the data to /clean directory.
# ============================================================

# ------------------------
# 1. Load Required Libraries
# ------------------------
library(readr)     # For reading CSV files
library(dplyr)     # For data manipulation
library(stringr)   # For string operations
library(janitor)   # For cleaning column names

# ------------------------
# 2. Set File Path and Load CSV
# ------------------------
file_path <- "C:/Users/Darren/Dev/fentanyl/data/raw/VSRR_Provisional_Drug_Overdose_Death_Counts_20250722.csv"

fentanyl_deaths <- read_csv(file_path)

# ------------------------
# 3. Filter for 2023 Data Only
# ------------------------
fentanyl_deaths_2023 <- fentanyl_deaths %>%
  filter(Year == 2023)

# ------------------------
# 4. Summarize Total National Deaths for 2023
# ------------------------
total_deaths_2023 <- fentanyl_deaths_2023 %>%
  summarise(total = sum(`Data Value`, na.rm = TRUE))

print(total_deaths_2023)

# ------------------------
# 5. Optional: Summarize Deaths by State (2023)
# ------------------------
if ("State" %in% colnames(fentanyl_deaths_2023)) {
  deaths_by_state <- fentanyl_deaths_2023 %>%
    group_by(State) %>%
    summarise(total_deaths = sum(`Data Value`, na.rm = TRUE)) %>%
    arrange(desc(total_deaths))
  
  print(deaths_by_state)
}

# ------------------------
# 6. Preview First Few Rows
# ------------------------
head(fentanyl_deaths_2023)

# ============================================================
# SECTION: CLEAN MORTALITY DATA
# PURPOSE: Standardize and clean the raw mortality dataset.
# ============================================================

# ------------------------
# 7. Load and Clean Data
# ------------------------
fentanyl_deaths_cleaned <- fentanyl_deaths %>%
  clean_names() %>%                                   # Clean column names
  mutate(across(where(is.character), str_squish)) %>% # Trim whitespace
  mutate(across(where(is.character), ~na_if(., ""))) %>%
  mutate(
    data_value = as.numeric(data_value),
    percent_complete = as.numeric(percent_complete),
    percent_pending_investigation = as.numeric(percent_pending_investigation),
    predicted_value = as.numeric(predicted_value)
  ) %>%
  filter(state %in% state.abb) %>%                    # Keep valid state abbreviations
  distinct()                                          # Remove duplicates

# ------------------------
# 8. Create Clean Directory (if not present)
# ------------------------
dir.create("C:/Users/Darren/Dev/fentanyl/data/clean", recursive = TRUE, showWarnings = FALSE)

# ------------------------
# 9. Save Cleaned Dataset
# ------------------------
write_csv(fentanyl_deaths_cleaned, "C:/Users/Darren/Dev/fentanyl/data/clean/fentanyl_deaths_cleaned.csv")

# ============================================================
# SECTION: VERIFY CLEANING
# PURPOSE: Perform basic QA checks on cleaned dataset.
# ============================================================

# ------------------------
# 10. Inspect Data Structure
# ------------------------
glimpse(fentanyl_deaths_cleaned)
colnames(fentanyl_deaths_cleaned)

# ------------------------
# 11. Unique States and Months
# ------------------------
unique(fentanyl_deaths_cleaned$state)
unique(fentanyl_deaths_cleaned$month)

# ------------------------
# 12. Check for Missing Values
# ------------------------
sapply(fentanyl_deaths_cleaned, function(x) sum(is.na(x)))

# ------------------------
# 13. Summary Statistics
# ------------------------
fentanyl_deaths_cleaned %>%
  summarise(
    total_rows = n(),
    total_data_value = sum(data_value, na.rm = TRUE),
    min_data_value = min(data_value, na.rm = TRUE),
    max_data_value = max(data_value, na.rm = TRUE)
  )

# ------------------------
# 14. Duplicate Check
# ------------------------
sum(duplicated(fentanyl_deaths_cleaned))
