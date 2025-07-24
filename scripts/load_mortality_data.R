library(readr)
library(dplyr)
library(stringr)

# Step 1: Set file path
file_path <- "C:/Users/Darren/Dev/fentanyl/data/raw/VSRR_Provisional_Drug_Overdose_Death_Counts_20250722.csv"

# Step 2: Load CSV
fentanyl_deaths <- read_csv(file_path)

# Step 3: Filter for 2023 data only
fentanyl_deaths_2023 <- fentanyl_deaths %>%
  filter(Year == 2023)

# Step 4: Summarize total fentanyl-related deaths nationally (sum of 'Data Value' column)
total_deaths_2023 <- fentanyl_deaths_2023 %>%
  summarise(total = sum(`Data Value`, na.rm = TRUE))

print(total_deaths_2023)

# Step 5 (Optional): Summarize deaths by state for 2023
if("State" %in% colnames(fentanyl_deaths_2023)){
  deaths_by_state <- fentanyl_deaths_2023 %>%
    group_by(State) %>%
    summarise(total_deaths = sum(`Data Value`, na.rm = TRUE)) %>%
    arrange(desc(total_deaths))
  
  print(deaths_by_state)
}

# Optional: First few rows for inspection
head(fentanyl_deaths_2023)

####
#CLEAN MORTALITY Data 

library(readr)
library(dplyr)
library(stringr)
library(janitor)

# Load raw dataset
file_path <- "C:/Users/Darren/Dev/fentanyl/data/raw/VSRR_Provisional_Drug_Overdose_Death_Counts_20250722.csv"
fentanyl_deaths <- read_csv(file_path)

# Clean dataset
fentanyl_deaths_cleaned <- fentanyl_deaths %>%
  janitor::clean_names() %>%
  mutate(across(where(is.character), ~str_squish(.))) %>%
  mutate(across(where(is.character), ~na_if(., ""))) %>%
  mutate(
    data_value = as.numeric(data_value),
    percent_complete = as.numeric(percent_complete),
    percent_pending_investigation = as.numeric(percent_pending_investigation),
    predicted_value = as.numeric(predicted_value)
  ) %>%
  filter(state %in% state.abb) %>%
  distinct()

# Save cleaned dataset
write_csv(fentanyl_deaths_cleaned, "C:/Users/Darren/Dev/fentanyl/data/clean/fentanyl_deaths_cleaned.csv")


# Verify cleaning of fentanyl_deaths_cleaned

# 1. Check structure and column names
glimpse(fentanyl_deaths_cleaned)
colnames(fentanyl_deaths_cleaned)

# 2. Check unique states and months
unique(fentanyl_deaths_cleaned$state)
unique(fentanyl_deaths_cleaned$month)

# 3. Check for missing values
sapply(fentanyl_deaths_cleaned, function(x) sum(is.na(x)))

# 4. Summary statistics for numeric columns
fentanyl_deaths_cleaned %>%
  summarise(
    total_rows = n(),
    total_data_value = sum(data_value, na.rm = TRUE),
    min_data_value = min(data_value, na.rm = TRUE),
    max_data_value = max(data_value, na.rm = TRUE)
  )

# 5. Check for duplicates
sum(duplicated(fentanyl_deaths_cleaned))

### # Create the clean directory if it doesn't exist
dir.create("C:/Users/Darren/Dev/fentanyl/data/clean", recursive = TRUE, showWarnings = FALSE)

# Save cleaned dataset
write_csv(fentanyl_deaths_cleaned, "C:/Users/Darren/Dev/fentanyl/data/clean/fentanyl_deaths_cleaned.csv")


###

# prescription data summary output

Row Count: 26,794,878 rows (this is a very large dataset, close to 27 million rows).

Column Count: 22 columns.

Column Types:
  
  Character columns (11):
  Examples: Prscrbr_Last_Org_Name, Prscrbr_First_Name, Prscrbr_City, Prscrbr_State_Abrvtn, Prscrbr_Type, Brnd_Name, Gnrc_Name, GE65_Sprsn_Flag, GE65_Bene_Sprsn_Flag.

Numeric columns (11):
  Examples: Prscrbr_NPI (prescriber ID), Tot_Clms (total claims), Tot_30day_Fills, Tot_Day_Suply, Tot_Drug_Cst, Tot_Benes (total beneficiaries), and the GE65 columns.

State Field: Prscrbr_State_Abrvtn uses standard state abbreviations (e.g., MD, OH).

Drug Fields:
  
  Brnd_Name: Brand name of the drug.

Gnrc_Name: Generic name of the drug.

Claims and Cost:
  
  Tot_Clms: Total number of prescriptions/claims per prescriber and drug.

Tot_Drug_Cst: Total drug cost (numeric).

Tot_Day_Suply: Total days of supply dispensed.

Special Flags:
  
  GE65_Sprsn_Flag and GE65_Bene_Sprsn_Flag contain symbols like * and # for suppressed or sensitive data (beneficiaries over 65).

Initial Observations:
  
  Some numeric fields (e.g., Tot_Benes, GE65 columns) have NA values due to data suppression.

There are multiple entries per prescriber (NPI) for each drug they prescribed.

###
# ============================================================
# SECTION: FILTER FENTANYL DEATHS TO SENIORS (65+)
# PURPOSE: Focus analysis on Medicare-age population to see if 
#          a relationship exists between prescriptions and deaths.
# ============================================================

library(dplyr)
library(stringr)
library(ggplot2)

# ------------------------------------------------------------
# 1. Filter Fentanyl Deaths by Seniors (65+)
# ------------------------------------------------------------
# NOTE: Ensure your fentanyl_deaths_cleaned dataset includes an age column. 
# If it’s labeled differently, update "age" to the correct column name.
# We'll keep only records where age >= 65.

fentanyl_deaths_seniors <- fentanyl_deaths_cleaned %>%
  filter(year == 2023) %>%              # Keep 2023 data only
  filter(age >= 65) %>%                 # Filter for seniors
  group_by(state) %>%                   # Aggregate by state
  summarise(total_deaths_65plus = sum(data_value, na.rm = TRUE)) %>%
  ungroup()

# ------------------------------------------------------------
# 2. Merge Senior Death Data with Prescriptions
# ------------------------------------------------------------
# Replace the previous death column with senior-specific data.

state_analysis_df_seniors <- state_analysis_df %>%
  select(-total_deaths) %>%  # Remove all-age death column
  left_join(fentanyl_deaths_seniors, by = "state")

# ------------------------------------------------------------
# 3. Calculate Senior-Specific Ratios
# ------------------------------------------------------------
# Prescriptions per senior death, etc.

state_analysis_df_seniors <- state_analysis_df_seniors %>%
  mutate(
    prescriptions_per_death_65plus = ifelse(total_deaths_65plus > 0,
                                            total_prescriptions / total_deaths_65plus, NA),
    fentanyl_prescriptions_per_death_65plus = ifelse(total_deaths_65plus > 0,
                                                     fentanyl_prescriptions / total_deaths_65plus, NA)
  )

# ------------------------------------------------------------
# 4. Correlation Analysis (65+)
# ------------------------------------------------------------
cor_total_65plus <- cor(state_analysis_df_seniors$total_prescriptions,
                        state_analysis_df_seniors$total_deaths_65plus,
                        use = "complete.obs", method = "pearson")

cor_fentanyl_65plus <- cor(state_analysis_df_seniors$fentanyl_prescriptions,
                           state_analysis_df_seniors$total_deaths_65plus,
                           use = "complete.obs", method = "pearson")

print(paste("Correlation (Total Prescriptions vs 65+ Deaths):", cor_total_65plus))
print(paste("Correlation (Fentanyl Prescriptions vs 65+ Deaths):", cor_fentanyl_65plus))

# ------------------------------------------------------------
# 5. Scatter Plots (65+ Deaths)
# ------------------------------------------------------------
plot_total_65plus <- ggplot(state_analysis_df_seniors,
                            aes(x = total_prescriptions, y = total_deaths_65plus)) +
  geom_point(color = "blue", size = 2) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Total Prescriptions vs. Fentanyl Deaths (65+, 2023)",
    x = "Total Prescriptions",
    y = "Fentanyl Deaths (65+)"
  ) +
  theme_minimal()

print(plot_total_65plus)

plot_fentanyl_65plus <- ggplot(state_analysis_df_seniors,
                               aes(x = fentanyl_prescriptions, y = total_deaths_65plus)) +
  geom_point(color = "darkgreen", size = 2) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Fentanyl Prescriptions vs. Fentanyl Deaths (65+, 2023)",
    x = "Fentanyl Prescriptions",
    y = "Fentanyl Deaths (65+)"
  ) +
  theme_minimal()

print(plot_fentanyl_65plus)

# ------------------------------------------------------------
# 6. Save Senior Analysis Data
# ------------------------------------------------------------
write_csv(state_analysis_df_seniors,
          "C:/Users/Darren/Dev/fentanyl/data/clean/state_analysis_df_seniors.csv")

# ------------------------------------------------------------
# 7. Verification
# ------------------------------------------------------------
glimpse(state_analysis_df_seniors)
# SCRIPT: Senior Fentanyl Death Analysis + Merge with Prescriptions
```r
# SCRIPT: Senior Fentanyl Death Analysis + Merge with Prescriptions
# PURPOSE:
#   1. Load and clean senior fentanyl death data (2023).
#   2. Merge with state-level prescription data.
#   3. Perform descriptive statistics and correlation analysis.
#   4. Generate scatterplots and histograms for seniors (65+).
# INPUT:
#   - Multiple Cause of Death, 2018-2023, Single Race.txt
#   - state_analysis_df.csv (cleaned prescriptions data)
# OUTPUT:
#   - senior_fentanyl_cleaned.csv
#   - senior_state_analysis.csv
#   - Plots and correlation results
# ============================================================

# ------------------------
# 1. Load Required Libraries
# ------------------------
library(readr)      # For reading/writing CSV files
library(dplyr)      # For data manipulation
library(janitor)    # For clean column names
library(stringr)    # For string manipulation
library(ggplot2)    # For plotting
library(tidyr)      # For handling NA values

# ------------------------
# 2. Load Raw Senior Death Data
# ------------------------
senior_fentanyl_file <- "C:/Users/Darren/Dev/fentanyl/data/raw/Multiple Cause of Death, 2018-2023, Single Race.txt"

senior_fentanyl <- read_delim(
  senior_fentanyl_file,
  delim = "\t",
  trim_ws = TRUE
)

# ------------------------
# 3. Clean Senior Death Data
# ------------------------
senior_fentanyl_cleaned <- senior_fentanyl %>%
  janitor::clean_names() %>%
  mutate(across(where(is.character), ~ str_squish(.))) %>%
  mutate(across(where(is.character), ~ na_if(., ""))) %>%
  rename(
    state_name = state,
    total_deaths_65plus = deaths
  ) %>%
  mutate(
    total_deaths_65plus = as.numeric(total_deaths_65plus),
    population = as.numeric(population),
    crude_rate = as.numeric(str_replace_all(crude_rate, "Unreliable", NA_character_))
  ) %>%
  filter(year == 2023) %>%
  filter(state_name %in% c(state.name, "District of Columbia")) %>%
  distinct()

# Save cleaned senior data
dir.create("C:/Users/Darren/Dev/fentanyl/data/clean", recursive = TRUE, showWarnings = FALSE)
write_csv(senior_fentanyl_cleaned, "C:/Users/Darren/Dev/fentanyl/data/clean/senior_fentanyl_cleaned.csv")

# ------------------------
# 4. Load Cleaned Prescription Data
# ------------------------
state_analysis_df <- read_csv("C:/Users/Darren/Dev/fentanyl/data/clean/state_analysis_df.csv")

# ------------------------
# 5. Merge Senior Death Data with Prescription Data
# ------------------------
# Match states by name or code
state_analysis_df <- state_analysis_df %>%
  mutate(state_name = state.name[match(state, state.abb)])

senior_state_analysis <- state_analysis_df %>%
  left_join(senior_fentanyl_cleaned, by = "state_name")

# Save merged dataset
write_csv(senior_state_analysis, "C:/Users/Darren/Dev/fentanyl/data/clean/senior_state_analysis.csv")

# ------------------------
# 6. Descriptive Statistics
# ------------------------
summary(senior_state_analysis[, c("total_prescriptions", "fentanyl_prescriptions", "total_deaths_65plus")])

# ------------------------
# 7. Correlation Analysis
# ------------------------
cor_total_seniors <- cor(
  senior_state_analysis$total_prescriptions,
  senior_state_analysis$total_deaths_65plus,
  use = "complete.obs",
  method = "pearson"
)

cor_fentanyl_seniors <- cor(
  senior_state_analysis$fentanyl_prescriptions,
  senior_state_analysis$total_deaths_65plus,
  use = "complete.obs",
  method = "pearson"
)

print(paste("Correlation (Total Prescriptions vs. Senior Deaths):", cor_total_seniors))
print(paste("Correlation (Fentanyl Prescriptions vs. Senior Deaths):", cor_fentanyl_seniors))

# ------------------------
# 8. Scatter Plots
# ------------------------
# Total prescriptions vs. senior deaths
plot_total_seniors <- ggplot(senior_state_analysis,
                             aes(x = total_prescriptions, y = total_deaths_65plus)) +
  geom_point(color = "blue", size = 2) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Total Prescriptions vs. Senior Fentanyl Deaths by State (2023)",
    x = "Total Prescriptions",
    y = "Total Senior Deaths (65+)"
  ) +
  theme_minimal()

print(plot_total_seniors)

# Fentanyl prescriptions vs. senior deaths
plot_fentanyl_seniors <- ggplot(senior_state_analysis,
                                aes(x = fentanyl_prescriptions, y = total_deaths_65plus)) +
  geom_point(color = "darkgreen", size = 2) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Fentanyl Prescriptions vs. Senior Fentanyl Deaths by State (2023)",
    x = "Fentanyl Prescriptions",
    y = "Total Senior Deaths (65+)"
  ) +
  theme_minimal()

print(plot_fentanyl_seniors)

# Save scatter plots
ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/scatter_total_vs_seniors.png",
       plot_total_seniors, width = 8, height = 6)

ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/scatter_fentanyl_vs_seniors.png",
       plot_fentanyl_seniors, width = 8, height = 6)

# ------------------------
# 9. Histogram of Senior Deaths
# ------------------------
hist_plot <- ggplot(senior_state_analysis, aes(x = total_deaths_65plus)) +
  geom_histogram(binwidth = 100, fill = "purple", color = "black") +
  labs(
    title = "Distribution of Senior Fentanyl Deaths by State (2023)",
    x = "Senior Fentanyl Deaths (65+)",
    y = "Frequency"
  ) +
  theme_minimal()

print(hist_plot)

ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/hist_senior_deaths.png",
       hist_plot, width = 8, height = 6)