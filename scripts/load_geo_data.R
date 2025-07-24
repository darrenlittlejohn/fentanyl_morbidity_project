# SCRIPT: Load and Clean Medicare Part D Geographic Prescriptions Dataset
# PURPOSE: This script loads the geographic-level Medicare Part D prescription dataset
#          (MUP_DPR_RY25_P04_V10_DY23_Geo.csv), cleans column names, handles missing values,
#          removes duplicates, and verifies the dataset structure and summary statistics.
# OUTPUT: A cleaned CSV saved to the 'data/clean' directory for analysis.

# ------------------------
# 1. Load Required Libraries
# ------------------------
library(readr)     # For reading CSV files
library(dplyr)     # For data manipulation (mutate, summarise, filter, etc.)
library(stringr)   # For string operations (e.g., trimming whitespace)
library(janitor)   # For cleaning column names to snake_case
library(tidyr)     # For handling missing values (replace_na, etc.)

# ------------------------
# 2. Load Raw Dataset
# ------------------------
# Define file path for the geographic-level prescription data
geo_prescriptions_file <- "C:/Users/Darren/Dev/fentanyl/data/raw/medicare_prescribers_by_geo_drug/MUP_DPR_RY25_P04_V10_DY23_Geo.csv"

# Read the raw CSV into R
geo_prescriptions_2023 <- read_csv(geo_prescriptions_file)

# ------------------------
# 3. Clean Dataset
# ------------------------
# - Clean column names
# - Remove extra whitespace
# - Convert empty strings to NA
# - Replace NA in numeric columns with 0
# - Remove duplicate rows
geo_prescriptions_2023_cleaned <- geo_prescriptions_2023 %>%
  janitor::clean_names() %>%
  mutate(across(where(is.character), ~str_squish(.))) %>%
  mutate(across(where(is.character), ~na_if(., ""))) %>%
  mutate(across(where(is.numeric), ~replace_na(., 0))) %>%
  distinct()

# ------------------------
# 4. Verify Cleaning
# ------------------------
# Check structure and column names
glimpse(geo_prescriptions_2023_cleaned)
colnames(geo_prescriptions_2023_cleaned)

# Count missing values for each column
sapply(geo_prescriptions_2023_cleaned, function(x) sum(is.na(x)))

# Generate summary statistics for all numeric columns (min, max)
geo_prescriptions_2023_cleaned %>%
  summarise(across(where(is.numeric),
                   list(min = ~min(., na.rm=TRUE),
                        max = ~max(., na.rm=TRUE))))

# Check for duplicate rows
sum(duplicated(geo_prescriptions_2023_cleaned))

# ------------------------
# 5. Save Cleaned Dataset
# ------------------------
# Create clean directory if it doesn't exist
dir.create("C:/Users/Darren/Dev/fentanyl/data/clean", recursive = TRUE, showWarnings = FALSE)

# Save cleaned data to CSV
write_csv(geo_prescriptions_2023_cleaned,
          "C:/Users/Darren/Dev/fentanyl/data/clean/geo_prescriptions_2023_cleaned.csv")
