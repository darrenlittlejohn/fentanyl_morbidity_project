# US Fentanyl Morbidity by USA, State and County

Two people I cared about died of fentanyl. This project is personal. The opioid crisis is not an abstract problem—it is a devastating reality that has touched my life and the lives of many people I know. Losing friends to fentanyl overdoses has changed the way I see this epidemic. I’ve been in recovery from addictions since 1984–1994 and 1997–current in 2025.

Since 2007 I’ve blogged, podcasted and written several books to help those suffering from addictions. It is with this background that the questions around fentanyl began to gnaw at my inner researcher. A search of publicly available datasets with fentanyl data yielded valid, well documented data sources to explore on this issue. Upon exploring of A,B,C datasets, the immediate question that arose is part one of this study. But let's frame up the context. 

The prima facie case is that the quantity of IMFs (Illicitly Manufactured Fentanyl) in the United States collectively and individually would be strongly related to overdose deaths. The CDC and others have this well established. 

According to the CDC, 82% of fentanyl overdose deaths in the U.S. involve IMFs rather than prescribed pharmaceutical fentanyl. This fact is crucial because it suggests that the majority of fentanyl-related fatalities arise from illegal sources, not from prescriptions. Our analysis explores whether there is any measurable relationship between the number of prescriptions written and the number of fentanyl deaths.

The prescription data used in this analysis is sourced from Medicare Part D prescribers, which primarily covers seniors (age 65+). Seniors receive fentanyl primarily through legitimate medical channels for pain management and palliative care, making their prescription patterns fundamentally different from illicit fentanyl use on the street. This distinction is a critical factor in interpreting the results: our analysis focuses on prescriptions within a population that is less likely to contribute to illicit fentanyl overdose statistics.

Most fentanyl overdose deaths, according to CDC data, occur among younger adults (25–54) due to illicit fentanyl. Seniors may typically have lower overdose death rates from illicit fentanyl, which refined the question to apply specifically to seniors 65+. 

## Central Question
**Is there a relationship between how much fentanyl is being prescribed to and the number of deaths by fentanyl overdose? - Is there a difference in regions, states, counties, or prescribers?**

This is not just an academic exercise or a technical showcase. This is about making sense of a tragedy that is unfolding all around us, and about providing something useful to others who are searching for answers—whether they are policymakers, public health workers, or people who have lost someone, as I have.

## Why This Project Matters
In the United States, the opioid crisis is a daily reality for millions of families and communities. The crisis is not uniform—some places are hit harder than others, and the reasons are complex. But at the center of it all is the question of how prescription patterns, especially for extremely potent opioids like fentanyl, relate to the loss of life we are seeing.

By focusing this project on a simple, direct question, I am intentionally choosing clarity over complexity, transparency over technical obscurity, and real-world relevance over academic abstraction.

## Objective
My goal is to create an analysis that anyone can understand, regardless of their background in statistics or data science. I want this project to be accessible to people who are grieving, to professionals trying to save lives, and to anyone who wants to understand what is actually happening in their own community.

## Project Workflow

### 1. Ask
Define the problem or question:
- Is there a relationship between fentanyl prescriptions and overdose deaths by region, state, county, or prescriber?

### 2. Prepare
Collect and clean relevant datasets:
- Medicare Part D Prescribers 2023
- CDC WONDER Multiple Cause of Death 2018–2023
- U.S. Census Bureau TIGER/Line Shapefiles

### 3. Process
Clean, merge, and preprocess data for analysis:
- Handle missing values
- Standardize fields
- Ensure data integrity

### 4. Analyze
Perform exploratory and statistical analyses:
- Summary statistics
- Visualizations
- Correlation analysis

### 5. Share
Present findings using:
- Quarto reports
- GitHub repository
- Visuals and tables

### 6. Act
- Discuss insights and implications
- Propose future research or recommendations

---

# Ask: Defining the Problem

## 🌡️ What is Fentanyl?
Fentanyl is a fully synthetic opioid analgesic, created in laboratories (no natural ingredients), originally developed in 1959 and approved in 1968. In medical settings, it’s used for severe pain (e.g., post-surgery, cancer).

## 💪 Potency Levels
- 50–100× stronger than morphine
- 30–50× stronger than heroin
- Lethal dose: ≈2 mg (about the same as a few grains of salt)
- Carfentanil: ~100× fentanyl, or 10,000× morphine

If morphine is a single step on a staircase, heroin takes you up 30 to 50 steps in a single stride. Fentanyl doesn’t just climb the stairs — it puts you atop a skyscraper, dangerously high above the ground. Carfentanil is not even in the building; it puts you above the skyscrapers into deep space, where survival is often impossible.

## ⚠️ When Is It Dangerous?
- Even trace amounts can cause fatal overdose
- Often mixed with counterfeit pills or heroin
- Most deaths involve illicitly made fentanyl (~70–80% in 2023)

## 🏛️ Prescription vs. Illicit
- **Pharmaceutical:** Prescribed legally for pain
- **Illicit:** Made illegally, sold as powder or counterfeit pills

## 📈 Fentanyl Influx

2023: Approximately 500lbs in 115M counterfeit pills seized.  
2024: Over 27,000 lbs of raw, powdered fentanyl seized.

Takeaway: 27,000 lbs (2024) vs. 507 lbs (2023 pills) = over 53× more fentanyl seized in 2024 compared to the pill-equivalent fentanyl from 2023.

### Summary Table
| Topic           | Key Facts                                     |
|-----------------|-----------------------------------------------|
| Pharmaceutical  | Schedule II, surgical/cancer pain             |
| Illicit         | Lab-made, found in counterfeit pills          |
| Potency         | 50–100× morphine; lethal dose ≈2 mg           |
| Analogs         | Carfentanil 100× fentanyl, 10,000× morphine    |
| Seizures        | 27k lbs (2024); 115M pills (2023)             |
| Overdose Deaths | ~70% fentanyl-related; ~72k in 2023           |

---

# Prepare Phase – Collect and Understand the Data

## Data Sources

### **Prescription Data:**
- **Name:** Medicare Part D Prescribers 2023
- **Format:** CSV
- **Source:** [CMS.gov](https://data.cms.gov/provider-summary-by-type-of-service/medicare-part-d-prescribers/medicare-part-d-prescribers-by-geography-and-drug/ry25-p04)
- **Notes:** Covers Medicare only

### **Overdose Data:**
- **Name:** CDC WONDER Multiple Cause of Death 2018–2023
- **Format:** CSV export
- **Source:** [CDC WONDER](https://wonder.cdc.gov/mcd-icd10.html)
- **Notes:** All-cause mortality; filtered for fentanyl codes

---

# Process Phase – Clean and Organize the Data

### Cleaning Methods:
- Removed duplicates
- Handled null values
- Corrected data types
- Standardized region names and codes
- Merged datasets by geography/time
- Filtered for relevant years and drug codes

### Tools Used:
- R: `tidyverse`, `janitor`, `readr`, `dplyr`, `lubridate`

---

# Analyze Phase – Explore and Identify Patterns

- **Trends/Outliers:** To be filled post-EDA
- **Methods Used:** Grouping, filtering, aggregating, correlation
- **Metrics/Visuals:** To be generated (scatter plots, state maps, correlation tables)

---

# Results

The EDA (Exploratory Data Analysis) showed a relationship of zero or slightly negative between fentanyl prescriptions and deaths nationwide, so I looked at each state with the same results. Then it occurred to me that since the Medicare data was limited to 65+ in most cases, it wasn't an apples-to-apples comparison against an all-ages mortality dataset.

A filter for age was then put in place and the EDA was rerun.

Since the mortality data covers all ages, I decided to filter for seniors 50+ in five-year groups and rerun everything. The results confirmed that there is no significant positive relationship between fentanyl prescriptions and overdoses either across all age groups or controlled for seniors.

**Correlation (Fentanyl Prescriptions vs. All-Age Deaths):** `-0.0855`  
**Correlation (Fentanyl Prescriptions vs. Senior Deaths):** `-0.1474`

---

## Figures

### Figure 1: Fentanyl Prescriptions vs. All-Age Fentanyl Deaths by State (2023)
![Figure 1](data/clean/scatter_fentanyl_vs_deaths.png)  
**Correlation:** -0.0855  
This plot shows the relationship between fentanyl prescriptions (Medicare Part D) and fentanyl deaths across all age groups in 2023. There is no strong positive correlation visible.

### Figure 2: Fentanyl Prescriptions vs. Senior (65+) Fentanyl Deaths by State (2023)
![Figure 2](data/clean/scatter_fentanyl_vs_seniors.png)  
**Correlation:** -0.1474  
This plot shows the relationship between fentanyl prescriptions (Medicare Part D) and fentanyl deaths specifically among seniors (65+). Again, no positive correlation is observed, reinforcing the finding that prescriptions are not driving fentanyl mortality among seniors.

---

# Share Phase – Present the Results

- **Delivery Tools:** Quarto, GitHub
- **Audience Targeting:** Accessible for laypeople and policymakers
- **Key Takeaways:** See Results and Figures section above.

---

# Act Phase – Recommend and Conclude

- **Recommendations:** Focus efforts on illicit fentanyl sources, not prescriptions, when targeting overdose interventions.
- **Impact Potential:** Inform policy, intervention, public education.
- **Next Steps:** Expand to county/regional analysis; include non-Medicare datasets.

---

# SMART Goal Summary

- **Specific:** Analyze U.S. fentanyl prescription and overdose data.
- **Measurable:** Compare fentanyl prescription volume to overdose rates.
- **Achievable:** Use public datasets (CMS, CDC, NCHS).
- **Relevant:** Address national opioid crisis.
- **Time-bound:** Deliver project by July 2025

---

# Next Steps

1. Add additional geographic breakdown (county-level if available).
2. Publish Quarto-based HTML and PDF reports.
3. Expand analysis to include synthetic opioid trends beyond fentanyl.
4. Post results to Medium, LinkedIn, and integrate visuals into GitHub README.
5. Create a YouTube breakdown (part-by-part) for outreach and educational purposes.
