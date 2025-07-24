# ============================================================
# SCRIPT: MASTER__02__ANALYSIS_VISUALIZATION.R
# PURPOSE:
#   1. Perform exploratory analysis on all datasets (national, state, senior).
#   2. Generate correlations and descriptive statistics.
#   3. Produce all visualizations: scatter plots, histograms, etc.
# INPUT:
#   - analysis_df_national.csv
#   - state_analysis_df.csv
#   - state_analysis_df_seniors.csv
# OUTPUT:
#   - Correlation results (console output).
#   - Plots saved to the 'data/clean/plots' directory.
# ============================================================

# ------------------------
# 1. Load Required Libraries
# ------------------------
library(readr)
library(dplyr)
library(ggplot2)
library(stringr)
library(janitor)

# ------------------------
# 2. Set Paths
# ------------------------
clean_path <- "C:/Users/Darren/Dev/fentanyl/data/clean/"
plots_path <- file.path(clean_path, "plots")

dir.create(plots_path, recursive = TRUE, showWarnings = FALSE)

# ------------------------
# 3. Load Data
# ------------------------
analysis_df_national <- read_csv(file.path(clean_path, "analysis_df_national.csv"))
state_analysis_df <- read_csv(file.path(clean_path, "state_analysis_df.csv"))
state_analysis_df_seniors <- read_csv(file.path(clean_path, "state_analysis_df_seniors.csv"))

# ------------------------
# 4. National-Level Analysis
# ------------------------
cat("\n==== NATIONAL ANALYSIS ====\n")
print(analysis_df_national)

# ------------------------
# 5. State-Level Correlation and Visualization
# ------------------------
cat("\n==== STATE-LEVEL ANALYSIS ====\n")

# Correlations
cor_state_total <- cor(
  state_analysis_df$total_prescriptions,
  state_analysis_df$total_deaths,
  use = "complete.obs",
  method = "pearson"
)

cor_state_fentanyl <- cor(
  state_analysis_df$fentanyl_prescriptions,
  state_analysis_df$total_deaths,
  use = "complete.obs",
  method = "pearson"
)

cat("Correlation (Total Prescriptions vs. Deaths):", cor_state_total, "\n")
cat("Correlation (Fentanyl Prescriptions vs. Deaths):", cor_state_fentanyl, "\n")

# Scatter plot: Total prescriptions vs. deaths
plot_total_state <- ggplot(state_analysis_df,
                           aes(x = total_prescriptions, y = total_deaths)) +
  geom_point(color = "blue", size = 2) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Total Prescriptions vs. Fentanyl Deaths by State (2023)",
    x = "Total Prescriptions",
    y = "Total Deaths"
  ) +
  theme_minimal()
print(plot_total_state)
ggsave(file.path(plots_path, "scatter_total_vs_deaths_state.png"),
       plot_total_state, width = 8, height = 6)

# Scatter plot: Fentanyl prescriptions vs. deaths
plot_fentanyl_state <- ggplot(state_analysis_df,
                              aes(x = fentanyl_prescriptions, y = total_deaths)) +
  geom_point(color = "darkgreen", size = 2) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Fentanyl Prescriptions vs. Fentanyl Deaths by State (2023)",
    x = "Fentanyl Prescriptions",
    y = "Total Deaths"
  ) +
  theme_minimal()
print(plot_fentanyl_state)
ggsave(file.path(plots_path, "scatter_fentanyl_vs_deaths_state.png"),
       plot_fentanyl_state, width = 8, height = 6)

# Histogram of state deaths
hist_state <- ggplot(state_analysis_df, aes(x = total_deaths)) +
  geom_histogram(binwidth = 500, fill = "purple", color = "black") +
  labs(
    title = "Distribution of Fentanyl Deaths by State (2023)",
    x = "Total Deaths",
    y = "Frequency"
  ) +
  theme_minimal()
print(hist_state)
ggsave(file.path(plots_path, "hist_deaths_state.png"), hist_state, width = 8, height = 6)

# ------------------------
# 6. Senior-Level Correlation and Visualization
# ------------------------
cat("\n==== SENIOR (65+) ANALYSIS ====\n")

# Correlations
cor_senior_total <- cor(
  state_analysis_df_seniors$total_prescriptions,
  state_analysis_df_seniors$total_deaths_65plus,
  use = "complete.obs",
  method = "pearson"
)

cor_senior_fentanyl <- cor(
  state_analysis_df_seniors$fentanyl_prescriptions,
  state_analysis_df_seniors$total_deaths_65plus,
  use = "complete.obs",
  method = "pearson"
)

cat("Correlation (Total Prescriptions vs. Senior Deaths):", cor_senior_total, "\n")
cat("Correlation (Fentanyl Prescriptions vs. Senior Deaths):", cor_senior_fentanyl, "\n")

# Scatter plot: Total prescriptions vs. senior deaths
plot_total_seniors <- ggplot(state_analysis_df_seniors,
                             aes(x = total_prescriptions, y = total_deaths_65plus)) +
  geom_point(color = "blue", size = 2) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Total Prescriptions vs. Fentanyl Deaths (65+, 2023)",
    x = "Total Prescriptions",
    y = "Senior Fentanyl Deaths (65+)"
  ) +
  theme_minimal()
print(plot_total_seniors)
ggsave(file.path(plots_path, "scatter_total_vs_seniors.png"),
       plot_total_seniors, width = 8, height = 6)

# Scatter plot: Fentanyl prescriptions vs. senior deaths
plot_fentanyl_seniors <- ggplot(state_analysis_df_seniors,
                                aes(x = fentanyl_prescriptions, y = total_deaths_65plus)) +
  geom_point(color = "darkgreen", size = 2) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(
    title = "Fentanyl Prescriptions vs. Fentanyl Deaths (65+, 2023)",
    x = "Fentanyl Prescriptions",
    y = "Senior Fentanyl Deaths (65+)"
  ) +
  theme_minimal()
print(plot_fentanyl_seniors)
ggsave(file.path(plots_path, "scatter_fentanyl_vs_seniors.png"),
       plot_fentanyl_seniors, width = 8, height = 6)

# Histogram of senior deaths
hist_seniors <- ggplot(state_analysis_df_seniors, aes(x = total_deaths_65plus)) +
  geom_histogram(binwidth = 50, fill = "orange", color = "black") +
  labs(
    title = "Distribution of Senior Fentanyl Deaths (65+, 2023)",
    x = "Senior Fentanyl Deaths (65+)",
    y = "Frequency"
  ) +
  theme_minimal()
print(hist_seniors)
ggsave(file.path(plots_path, "hist_senior_deaths.png"), hist_seniors, width = 8, height = 6)

# ------------------------
# 7. Completion
# ------------------------
cat("\nAnalysis and visualization complete. Plots saved in:\n", plots_path, "\n")
