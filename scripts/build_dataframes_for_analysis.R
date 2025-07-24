# SCRIPT: Build National and State Analysis Data Frames (FINAL VERSION)
# PURPOSE:
#   1. Load and aggregate prescription and mortality data.
#   2. Create both national-level and state-level analysis data frames.
#   3. Save clean outputs for analysis with no redundant columns.
# INPUT FILES:
#   - fentanyl_deaths_cleaned.csv
#   - geo_prescriptions_2023_cleaned.csv
# OUTPUT FILES:
#   - analysis_df_national.csv
#   - state_analysis_df.csv

# ------------------------
# 1. Load Required Libraries
# ------------------------
library(readr)       # For reading and writing CSV files
library(dplyr)       # For grouping, aggregating, and joining
library(stringr)     # For text matching
library(janitor)     # For clean_names

# ------------------------
# 2. Load Cleaned Data
# ------------------------
fentanyl_deaths_cleaned <- read_csv("C:/Users/Darren/Dev/fentanyl/data/clean/fentanyl_deaths_cleaned.csv")
geo_prescriptions_2023_cleaned <- read_csv("C:/Users/Darren/Dev/fentanyl/data/clean/geo_prescriptions_2023_cleaned.csv")

# ------------------------
# 3. National-Level Analysis Data Frame
# ------------------------

# Total deaths (national) for 2023
deaths_national_2023 <- fentanyl_deaths_cleaned %>%
  filter(year == 2023) %>%
  summarise(total_deaths = sum(data_value, na.rm = TRUE))

# Total prescriptions (all drugs) for 2023
prescriptions_national_2023 <- geo_prescriptions_2023_cleaned %>%
  summarise(total_prescriptions = sum(tot_clms, na.rm = TRUE))

# Total fentanyl prescriptions for 2023
fentanyl_prescriptions_national_2023 <- geo_prescriptions_2023_cleaned %>%
  filter(str_detect(gnrc_name, regex("fentanyl", ignore_case = TRUE))) %>%
  summarise(
    fentanyl_prescriptions = sum(tot_clms, na.rm = TRUE),
    fentanyl_cost = sum(tot_drug_cst, na.rm = TRUE)
  )

# Create the national analysis data frame
analysis_df_national <- data.frame(
  year = 2023,
  total_prescriptions = prescriptions_national_2023$total_prescriptions,
  fentanyl_prescriptions = fentanyl_prescriptions_national_2023$fentanyl_prescriptions,
  fentanyl_cost = fentanyl_prescriptions_national_2023$fentanyl_cost,
  total_deaths = deaths_national_2023$total_deaths
)

# Save national-level analysis
write_csv(analysis_df_national, "C:/Users/Darren/Dev/fentanyl/data/clean/analysis_df_national.csv")

# ------------------------
# 4. State-Level Analysis Data Frame
# ------------------------

# Create a FIPS-to-state lookup table
fips_lookup <- data.frame(
  fips = sprintf("%02d", 1:56),
  state = c(
    "AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA",
    "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD",
    "MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ",
    "NM","NY","NC","ND","OH","OK","OR","PA","RI","SC",
    "SD","TN","TX","UT","VT","VA","WA","WV","WI","WY",
    "DC","PR","GU","VI","MP","AS"
  )
)

# Total prescriptions per state
state_prescriptions_2023 <- geo_prescriptions_2023_cleaned %>%
  group_by(prscrbr_geo_cd) %>%
  summarise(total_prescriptions = sum(tot_clms, na.rm = TRUE)) %>%
  left_join(fips_lookup, by = c("prscrbr_geo_cd" = "fips")) %>%
  select(state, total_prescriptions)

# Fentanyl prescriptions per state
state_fentanyl_prescriptions_2023 <- geo_prescriptions_2023_cleaned %>%
  filter(str_detect(gnrc_name, regex("fentanyl", ignore_case = TRUE))) %>%
  group_by(prscrbr_geo_cd) %>%
  summarise(
    fentanyl_prescriptions = sum(tot_clms, na.rm = TRUE),
    fentanyl_cost = sum(tot_drug_cst, na.rm = TRUE)
  ) %>%
  left_join(fips_lookup, by = c("prscrbr_geo_cd" = "fips")) %>%
  select(state, fentanyl_prescriptions, fentanyl_cost)

# Fentanyl deaths per state (2023)
state_deaths_2023 <- fentanyl_deaths_cleaned %>%
  filter(year == 2023) %>%
  group_by(state) %>%
  summarise(total_deaths = sum(data_value, na.rm = TRUE))

# Merge all state-level data into one data frame
state_analysis_df <- state_prescriptions_2023 %>%
  left_join(state_fentanyl_prescriptions_2023, by = "state") %>%
  left_join(state_deaths_2023, by = "state")

# Save state-level analysis
write_csv(state_analysis_df, "C:/Users/Darren/Dev/fentanyl/data/clean/state_analysis_df.csv")

# ------------------------
# 5. Verification
# ------------------------
glimpse(analysis_df_national)
glimpse(state_analysis_df)


###

# SCRIPT: State-Level Statistical Analysis
# PURPOSE:
#   1. Analyze the relationship between prescription counts and fentanyl deaths by state.
#   2. Compute ratios (e.g., prescriptions per death).
#   3. Calculate correlations (Pearson).
#   4. Produce scatter plots for visual analysis.
# INPUT:
#   - state_analysis_df.csv
# OUTPUT:
#   - state_analysis_df_enhanced.csv
#   - scatter plots saved as PNG files

# ------------------------
# 1. Load Required Libraries
# ------------------------
library(readr)      # For reading and writing CSVs
library(dplyr)      # For data manipulation
library(ggplot2)    # For visualization
library(stats)      # For correlation calculations

# ------------------------
# 2. Load State-Level Data
# ------------------------
state_analysis_df <- read_csv("C:/Users/Darren/Dev/fentanyl/data/clean/state_analysis_df.csv")

# ------------------------
# 3. Compute Ratios
# ------------------------
# Add columns for prescriptions per death and fentanyl prescriptions per death
state_analysis_df <- state_analysis_df %>%
  mutate(
    prescriptions_per_death = ifelse(total_deaths > 0,
                                     total_prescriptions / total_deaths, NA),
    fentanyl_prescriptions_per_death = ifelse(total_deaths > 0,
                                              fentanyl_prescriptions / total_deaths, NA)
  )

# ------------------------
# 4. Correlation Analysis
# ------------------------
# Pearson correlation: total prescriptions vs. total deaths
cor_total <- cor(state_analysis_df$total_prescriptions,
                 state_analysis_df$total_deaths,
                 use = "complete.obs",
                 method = "pearson")

# Pearson correlation: fentanyl prescriptions vs. total deaths
cor_fentanyl <- cor(state_analysis_df$fentanyl_prescriptions,
                    state_analysis_df$total_deaths,
                    use = "complete.obs",
                    method = "pearson")

# Print correlation results
print(paste("Correlation (Total Prescriptions vs. Deaths):", cor_total))
print(paste("Correlation (Fentanyl Prescriptions vs. Deaths):", cor_fentanyl))

# ------------------------
# 5. Scatter Plots
# ------------------------
# Scatter plot: total prescriptions vs. deaths
plot_total <- ggplot(state_analysis_df,
                     aes(x = total_prescriptions, y = total_deaths)) +
  geom_point(color = "blue", size = 2) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Total Prescriptions vs. Fentanyl Deaths by State (2023)",
    x = "Total Prescriptions",
    y = "Total Deaths"
  ) +
  theme_minimal()

# Save scatter plot for total prescriptions vs. deaths
ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/scatter_total_vs_deaths.png",
       plot_total, width = 8, height = 6)

# Scatter plot: fentanyl prescriptions vs. deaths
plot_fentanyl <- ggplot(state_analysis_df,
                        aes(x = fentanyl_prescriptions, y = total_deaths)) +
  geom_point(color = "darkgreen", size = 2) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Fentanyl Prescriptions vs. Fentanyl Deaths by State (2023)",
    x = "Fentanyl Prescriptions",
    y = "Total Deaths"
  ) +
  theme_minimal()

# Save scatter plot for fentanyl prescriptions vs. deaths
ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/scatter_fentanyl_vs_deaths.png",
       plot_fentanyl, width = 8, height = 6)

# ------------------------
# 6. Save Enhanced Data Frame
# ------------------------
write_csv(state_analysis_df, "C:/Users/Darren/Dev/fentanyl/data/clean/state_analysis_df_enhanced.csv")

# ------------------------
# 7. Verification
# ------------------------
glimpse(state_analysis_df)

###
# ------------------------
# 5. Scatter Plots (Display + Save)
# ------------------------

# Scatter plot: total prescriptions vs. deaths
plot_total <- ggplot(state_analysis_df,
                     aes(x = total_prescriptions, y = total_deaths)) +
  geom_point(color = "blue", size = 2) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Total Prescriptions vs. Fentanyl Deaths by State (2023)",
    x = "Total Prescriptions",
    y = "Total Deaths"
  ) +
  theme_minimal()

# Display the plot in RStudio
print(plot_total)

# Save scatter plot for total prescriptions vs. deaths
ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/scatter_total_vs_deaths.png",
       plot_total, width = 8, height = 6)

# Scatter plot: fentanyl prescriptions vs. deaths
plot_fentanyl <- ggplot(state_analysis_df,
                        aes(x = fentanyl_prescriptions, y = total_deaths)) +
  geom_point(color = "darkgreen", size = 2) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Fentanyl Prescriptions vs. Fentanyl Deaths by State (2023)",
    x = "Fentanyl Prescriptions",
    y = "Total Deaths"
  ) +
  theme_minimal()

# Display the plot in RStudio
print(plot_fentanyl)

# Save scatter plot for fentanyl prescriptions vs. deaths
ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/scatter_fentanyl_vs_deaths.png",
       plot_fentanyl, width = 8, height = 6)


###
# SCRIPT: Refined Correlation Analysis (State-Level)
# PURPOSE:
#   1. Refine the state-level dataset by removing territories (PR, GU, VI, MP, AS).
#   2. Recalculate correlations across the 50 states + DC + AK + HI only.
#   3. Investigate state-by-state relationships (correlation within each state if relevant).
#   4. Provide a clean, strategic analysis structure to demonstrate thoughtful filtering and robust methodology.
# INPUT:
#   - state_analysis_df_enhanced.csv
# OUTPUT:
#   - state_analysis_df_filtered.csv
#   - updated correlations and summary.

# ------------------------
# 1. Load Required Libraries
# ------------------------
library(readr)    # For reading/writing CSV files
library(dplyr)    # For filtering, summarizing
library(ggplot2)  # For plotting
library(stats)    # For correlation

# ------------------------
# 2. Load Enhanced State-Level Data
# ------------------------
state_analysis_df <- read_csv("C:/Users/Darren/Dev/fentanyl/data/clean/state_analysis_df_enhanced.csv")

# ------------------------
# 3. Remove Territories
# ------------------------
# Territories (PR, GU, VI, MP, AS) are removed to focus on continental U.S., Alaska, and Hawaii.
# This avoids skewing results with incomplete or incomparable reporting from territories.
state_analysis_filtered <- state_analysis_df %>%
  filter(!(state %in% c("PR", "GU", "VI", "MP", "AS")))

# Save filtered dataset
write_csv(state_analysis_filtered, "C:/Users/Darren/Dev/fentanyl/data/clean/state_analysis_df_filtered.csv")

# ------------------------
# 4. Recalculate Correlations (All States Only)
# ------------------------
# Correlation for total prescriptions vs deaths
cor_total_states <- cor(state_analysis_filtered$total_prescriptions,
                        state_analysis_filtered$total_deaths,
                        use = "complete.obs",
                        method = "pearson")

# Correlation for fentanyl prescriptions vs deaths
cor_fentanyl_states <- cor(state_analysis_filtered$fentanyl_prescriptions,
                           state_analysis_filtered$total_deaths,
                           use = "complete.obs",
                           method = "pearson")

print(paste("Correlation (Total Prescriptions vs Deaths, States Only):", cor_total_states))
print(paste("Correlation (Fentanyl Prescriptions vs Deaths, States Only):", cor_fentanyl_states))

# ------------------------
# 5. State-by-State Analysis
# ------------------------
# Logic:
# While correlation is typically calculated across observations, we can assess the
# strength of relationship per state by comparing ratios (prescriptions_per_death)
# and identifying outliers or patterns rather than simple per-state correlations
# (since each state is only a single observation for 2023).
#
# We'll highlight states with extreme prescriptions_per_death ratios to examine local anomalies.

# Identify top and bottom 5 states by prescriptions per death
top_states <- state_analysis_filtered %>%
  arrange(desc(prescriptions_per_death)) %>%
  head(5)

bottom_states <- state_analysis_filtered %>%
  arrange(prescriptions_per_death) %>%
  head(5)

print("Top 5 States by Prescriptions per Death:")
print(top_states)
print("Bottom 5 States by Prescriptions per Death:")
print(bottom_states)

# ------------------------
# 6. Scatter Plots (Filtered States)
# ------------------------
# Updated scatter plots excluding territories

plot_total_filtered <- ggplot(state_analysis_filtered,
                              aes(x = total_prescriptions, y = total_deaths)) +
  geom_point(color = "blue", size = 2) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Total Prescriptions vs. Fentanyl Deaths (States Only, 2023)",
    x = "Total Prescriptions",
    y = "Total Deaths"
  ) +
  theme_minimal()

print(plot_total_filtered)

ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/scatter_total_vs_deaths_states.png",
       plot_total_filtered, width = 8, height = 6)

plot_fentanyl_filtered <- ggplot(state_analysis_filtered,
                                 aes(x = fentanyl_prescriptions, y = total_deaths)) +
  geom_point(color = "darkgreen", size = 2) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Fentanyl Prescriptions vs. Fentanyl Deaths (States Only, 2023)",
    x = "Fentanyl Prescriptions",
    y = "Total Deaths"
  ) +
  theme_minimal()

print(plot_fentanyl_filtered)

ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/scatter_fentanyl_vs_deaths_states.png",
       plot_fentanyl_filtered, width = 8, height = 6)

# ------------------------
# 7. Verification
# ------------------------
glimpse(state_analysis_filtered)



###
# SCRIPT: State-Level Distribution & Relationship Analysis
# PURPOSE:
#   1. Explore the distributions of prescriptions, deaths, and ratios across states.
#   2. Produce histograms and density plots (bell curves) to visualize distributions.
#   3. Investigate if any individual state shows a strong relationship between prescriptions and deaths.
# INPUT:
#   - state_analysis_df_filtered.csv
# OUTPUT:
#   - histograms and density plots (PNG)
#   - summary statistics and key state insights

# ------------------------
# 1. Load Libraries and Data
# ------------------------
library(readr)
library(dplyr)
library(ggplot2)
library(stats)

state_analysis_filtered <- read_csv("C:/Users/Darren/Dev/fentanyl/data/clean/state_analysis_df_filtered.csv")

# ------------------------
# 2. Distribution Analysis
# ------------------------
# We examine the distributions of total prescriptions, fentanyl prescriptions, and deaths.
# Histograms give a frequency distribution, while density plots show a smooth curve for shape.

# Histogram: Total prescriptions
hist_total <- ggplot(state_analysis_filtered, aes(x = total_prescriptions)) +
  geom_histogram(bins = 20, fill = "steelblue", color = "black") +
  labs(title = "Distribution of Total Prescriptions by State",
       x = "Total Prescriptions", y = "Frequency") +
  theme_minimal()

print(hist_total)
ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/hist_total_prescriptions.png", hist_total, width = 8, height = 6)

# Histogram: Fentanyl prescriptions
hist_fentanyl <- ggplot(state_analysis_filtered, aes(x = fentanyl_prescriptions)) +
  geom_histogram(bins = 20, fill = "darkgreen", color = "black") +
  labs(title = "Distribution of Fentanyl Prescriptions by State",
       x = "Fentanyl Prescriptions", y = "Frequency") +
  theme_minimal()

print(hist_fentanyl)
ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/hist_fentanyl_prescriptions.png", hist_fentanyl, width = 8, height = 6)

# Histogram: Deaths
hist_deaths <- ggplot(state_analysis_filtered, aes(x = total_deaths)) +
  geom_histogram(bins = 20, fill = "firebrick", color = "black") +
  labs(title = "Distribution of Fentanyl Deaths by State",
       x = "Total Deaths", y = "Frequency") +
  theme_minimal()

print(hist_deaths)
ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/hist_total_deaths.png", hist_deaths, width = 8, height = 6)

# ------------------------
# 3. Density (Bell Curve) Plots
# ------------------------
# Density plots give a smoother view of the distribution, akin to a bell curve.

density_total <- ggplot(state_analysis_filtered, aes(x = total_prescriptions)) +
  geom_density(fill = "steelblue", alpha = 0.6) +
  labs(title = "Density of Total Prescriptions by State",
       x = "Total Prescriptions") +
  theme_minimal()

print(density_total)
ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/density_total_prescriptions.png", density_total, width = 8, height = 6)

density_fentanyl <- ggplot(state_analysis_filtered, aes(x = fentanyl_prescriptions)) +
  geom_density(fill = "darkgreen", alpha = 0.6) +
  labs(title = "Density of Fentanyl Prescriptions by State",
       x = "Fentanyl Prescriptions") +
  theme_minimal()

print(density_fentanyl)
ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/density_fentanyl_prescriptions.png", density_fentanyl, width = 8, height = 6)

density_deaths <- ggplot(state_analysis_filtered, aes(x = total_deaths)) +
  geom_density(fill = "firebrick", alpha = 0.6) +
  labs(title = "Density of Fentanyl Deaths by State",
       x = "Total Deaths") +
  theme_minimal()

print(density_deaths)
ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/density_total_deaths.png", density_deaths, width = 8, height = 6)

# ------------------------
# 4. Identify States with Strong Ratios
# ------------------------
# We flag states with extreme ratios (prescriptions_per_death or fentanyl_prescriptions_per_death).

state_analysis_filtered <- state_analysis_filtered %>%
  mutate(
    high_ratio_flag = prescriptions_per_death > quantile(prescriptions_per_death, 0.9, na.rm = TRUE),
    low_ratio_flag  = prescriptions_per_death < quantile(prescriptions_per_death, 0.1, na.rm = TRUE)
  )

top_ratio_states <- state_analysis_filtered %>%
  filter(high_ratio_flag) %>%
  select(state, total_prescriptions, total_deaths, prescriptions_per_death)

bottom_ratio_states <- state_analysis_filtered %>%
  filter(low_ratio_flag) %>%
  select(state, total_prescriptions, total_deaths, prescriptions_per_death)

print("Top 10% of States by Prescriptions per Death:")
print(top_ratio_states)
print("Bottom 10% of States by Prescriptions per Death:")
print(bottom_ratio_states)

# ------------------------
# 5. State-Level Relationship Check
# ------------------------
# With only one observation per state (2023 totals), traditional correlation within each
# state isn't possible. Instead, we evaluate:
#   - Which states have a relatively high or low prescriptions-to-death ratio?
#   - Which states are outliers in scatter plots?

# Highlight outliers in fentanyl scatter plot
plot_fentanyl_outliers <- ggplot(state_analysis_filtered,
                                 aes(x = fentanyl_prescriptions, y = total_deaths, label = state)) +
  geom_point(color = "darkgreen", size = 2) +
  geom_text(check_overlap = TRUE, vjust = -0.5) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Fentanyl Prescriptions vs Deaths (State-Level, 2023)",
    x = "Fentanyl Prescriptions",
    y = "Total Deaths"
  ) +
  theme_minimal()

print(plot_fentanyl_outliers)
ggsave("C:/Users/Darren/Dev/fentanyl/data/clean/scatter_fentanyl_outliers.png",
       plot_fentanyl_outliers, width = 8, height = 6)

# ------------------------
# 6. Verification
# ------------------------
glimpse(state_analysis_filtered)

