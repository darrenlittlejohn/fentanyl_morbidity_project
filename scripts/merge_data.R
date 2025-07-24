## --- Load required libraries ---
library(readr)       # File reading
library(dplyr)       # Data wrangling
library(janitor)     # Clean column names

# --- Load mortality_data ---
mortality_data <- read_tsv(
  "C:/Users/Darren/Dev/fentanyl/data/raw/",
  col_names = TRUE,
  na = c("", "NA", "NaN"),
  show_col_types = FALSE
) %>%
  clean_names()

# --- Load prescribers_by_geo ---
prescribers_by_geo <- read_csv(
  "C:/Users/Darren/Dev/fentanyl/data/raw/medicare_prescribers_by_geo_drug/MUP_DPR_RY25_P04_V10_DY23_Geo.csv",
  na = c("", "NA", "NaN"),
  show_col_types = FALSE
) %>%
  clean_names()

# --- Load nchs_overdose ---
nchs_overdose <- read_csv(
  "C:/Users/Darren/Dev/fentanyl/data/raw/cdc_nchs_VSRR_Provisional_Drug_Overdose_Death_Counts.csv",
  na = c("", "NA", "NaN"),
  show_col_types = FALSE
) %>%
  clean_names()

# --- Harmonize state column names ---
nchs_overdose <- nchs_overdose %>%
  mutate(state_full = case_when(
    state == "AK" ~ "Alaska",
    state == "AL" ~ "Alabama",
    state == "AR" ~ "Arkansas",
    state == "AZ" ~ "Arizona",
    state == "CA" ~ "California",
    state == "CO" ~ "Colorado",
    state == "CT" ~ "Connecticut",
    state == "DC" ~ "District of Columbia",
    state == "DE" ~ "Delaware",
    state == "FL" ~ "Florida",
    state == "GA" ~ "Georgia",
    state == "HI" ~ "Hawaii",
    state == "IA" ~ "Iowa",
    state == "ID" ~ "Idaho",
    state == "IL" ~ "Illinois",
    state == "IN" ~ "Indiana",
    state == "KS" ~ "Kansas",
    state == "KY" ~ "Kentucky",
    state == "LA" ~ "Louisiana",
    state == "MA" ~ "Massachusetts",
    state == "MD" ~ "Maryland",
    state == "ME" ~ "Maine",
    state == "MI" ~ "Michigan",
    state == "MN" ~ "Minnesota",
    state == "MO" ~ "Missouri",
    state == "MS" ~ "Mississippi",
    state == "MT" ~ "Montana",
    state == "NC" ~ "North Carolina",
    state == "ND" ~ "North Dakota",
    state == "NE" ~ "Nebraska",
    state == "NH" ~ "New Hampshire",
    state == "NJ" ~ "New Jersey",
    state == "NM" ~ "New Mexico",
    state == "NV" ~ "Nevada",
    state == "NY" ~ "New York",
    state == "OH" ~ "Ohio",
    state == "OK" ~ "Oklahoma",
    state == "OR" ~ "Oregon",
    state == "PA" ~ "Pennsylvania",
    state == "PR" ~ "Puerto Rico",
    state == "RI" ~ "Rhode Island",
    state == "SC" ~ "South Carolina",
    state == "SD" ~ "South Dakota",
    state == "TN" ~ "Tennessee",
    state == "TX" ~ "Texas",
    state == "UT" ~ "Utah",
    state == "VA" ~ "Virginia",
    state == "VT" ~ "Vermont",
    state == "WA" ~ "Washington",
    state == "WI" ~ "Wisconsin",
    state == "WV" ~ "West Virginia",
    state == "WY" ~ "Wyoming",
    TRUE ~ NA_character_
  ))

# --- Merge mortality_data with prescribers_by_geo ---
merged_data <- mortality_data %>%
  inner_join(prescribers_by_geo, by = c("state" = "prscrbr_geo_desc"))

# --- Merge result with nchs_overdose using full state name ---
merged_data <- merged_data %>%
  inner_join(nchs_overdose, by = c("state" = "state_full"))

# --- Inspect merged data ---
str(merged_data)
head(merged_data, 10)

###table(duplicated(mortality_data$state))
table(duplicated(prescribers_by_geo$prscrbr_geo_desc))
table(duplicated(nchs_overdose$state_full))


###
# --- Filter each dataset for fentanyl/fentanyl analogs only ---
mortality_fentanyl <- mortality_data %>%
  filter(grepl("fentanyl", tolower(notes)))   # adjust column as needed

prescribers_fentanyl <- prescribers_by_geo %>%
  filter(grepl("fentanyl", tolower(brnd_name)) | grepl("fentanyl", tolower(gnrc_name)))

nchs_fentanyl <- nchs_overdose %>%
  filter(grepl("fentanyl", tolower(indicator)))

# --- Example: Aggregate counts by state ---
mortality_agg <- mortality_fentanyl %>%
  group_by(state) %>%
  summarise(deaths = sum(as.numeric(deaths), na.rm = TRUE))

prescribers_agg <- prescribers_fentanyl %>%
  group_by(prscrbr_geo_desc) %>%
  summarise(prescriptions = sum(tot_clms, na.rm = TRUE))

nchs_agg <- nchs_fentanyl %>%
  group_by(state_full) %>%
  summarise(overdose_count = sum(data_value, na.rm = TRUE))

mortality_agg


###
# --- Filter mortality_data for fentanyl-related deaths ---
# Fentanyl and its analogs are identified by ICD-10 codes T40.4 and T40.6.
mortality_fentanyl <- mortality_data %>%
  filter(icd_code %in% c("T40.4", "T40.6") |
           multiple_cause_1 %in% c("T40.4", "T40.6") |
           multiple_cause_2 %in% c("T40.4", "T40.6") |
           multiple_cause_3 %in% c("T40.4", "T40.6") |
           multiple_cause_4 %in% c("T40.4", "T40.6") |
           multiple_cause_5 %in% c("T40.4", "T40.6"))

# --- Inspect column names in mortality_data ---
colnames(mortality_data)

# --- Preview first few rows of mortality_data ---
head(mortality_data, 10)


# --- View first 20 rows of filtered data for verification ---
head(mortality_fentanyl, 20)



