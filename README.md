# US Fentanyl Morbidity by USA, State and County

Two people I cared about died of fentanyl. This project is personal. The opioid crisis is not an abstract problem—it is a devastating reality that has touched my life and the lives of many people I know. Losing friends to fentanyl overdoses has changed the way I see this epidemic. I’ve been in recovery from addictions since 1984–1994 and 1997–current in 2025.

Since 2007 I’ve blogged, podcasted and written several books to help those suffering from addictions. It is with this background that the questions around fentanyl began to gnaw at my inner researcher. A search of publicly available datasets with fentanyl data yielded valid, well documented data sources to explore on this issue. Upon exploring of A,B,C datasets, the immediate question that arose is part one of this study.

## Central Question
**Is there a relationship between how much fentanyl is being prescribed and the number of deaths by fentanyl overdose?**

- Is there a difference in regions, states, counties, or prescribers?

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

This massive spike in bulk powder seizures from 2023 to 2024 suggests a shift from counterfeit pill seizures to larger quantities of raw fentanyl being intercepted.

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

# Fentanyl FAQ

**Q1: What is fentanyl derived from?**  
A: Completely synthetic (not opium-derived); based on phenylpiperidine.  

**Q2: How does fentanyl's potency compare?**  
A: Morphine → Heroin (~30–50×) → Fentanyl (~50–100×) → Carfentanil (~100× fentanyl)  

**Q3: What level is dangerous?**  
A: Anything over 2 mg. Mixing with other drugs increases risk dramatically.  

**Q4: How is it accessed?**  
A: Prescription (patches, lozenges, injectables) or Illicit (powder, fake pills)  

**Q5: How much is being smuggled?**  
A: 27,000 lbs seized; 115M fake pills in 2023  

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

### **Geography Data:**
- **Name:** U.S. Census TIGER/Line Shapefiles
- **Format:** Shapefile
- **Source:** [Census.gov](https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.html)

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

### Data Frames
| Data Frame | Variable Name             | Source Dataset                         |
|------------|---------------------------|----------------------------------------|
| DF1        | State_Name                | Medicare Part D Prescribers            |
|            | State_FIPS                | Medicare Part D Prescribers            |
|            | Fentanyl_Prescriptions    | Medicare Part D Prescribers            |
| DF2        | State_Name                | CDC Mortality Data                     |
|            | Fentanyl_Deaths           | CDC Mortality Data                     |
|            | Total_Overdose_Deaths     | CDC Mortality Data                     |
| DF3        | State_Name                | NCHS Provisional Overdose Death Counts |
|            | Reported_Overdose_Deaths  | NCHS Provisional Overdose Death Counts |
|            | Predicted_Overdose_Deaths | NCHS Provisional Overdose Death Counts |

---

# Analyze Phase – Explore and Identify Patterns

- **Trends/Outliers:** To be filled post-EDA
- **Methods Used:** Grouping, filtering, aggregating, correlation
- **Metrics/Visuals:** To be generated (scatter plots, state maps, correlation tables)

---

# Share Phase – Present the Results

- **Delivery Tools:** Quarto, GitHub
- **Audience Targeting:** Accessible for laypeople and policymakers
- **Key Takeaways:** To be inserted post-analysis

---

# Act Phase – Recommend and Conclude

- **Recommendations:** Based on findings
- **Impact Potential:** Inform policy, intervention, public education
- **Next Steps:** Expand to county/regional analysis; include non-Medicare data

---

# SMART Goal Summary

- **Specific:** Analyze U.S. fentanyl prescription and overdose data
- **Measurable:** Compare prescription volume to overdose rates
- **Achievable:** Use public datasets (CMS, CDC, NCHS)
- **Relevant:** Address national opioid crisis
- **Time-bound:** Deliver project by July 2025
