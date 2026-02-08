# Effects of Glucose-lowering Medications on Functional Parameters of the Central Nervous System in Type 2 Diabetes Mellitus

## Project Description

This project investigates whether two modern glucose-lowering drug classes, sodium-glucose co-transporter 2 inhibitors (SGLT2i) and glucagon-like peptide-1 receptor agonists (GLP-1 RA), influence cognitive function and biochemical markers of neuronal damage in patients with type 2 diabetes mellitus (T2DM).

The analysis is based on a prospective observational cohort study with a 12 month follow-up and includes longitudinal modeling, causal inference techniques, and missing data imputation.

## Aim

To evaluate the effect of SGLT2i and GLP-1 RA therapy on functional parameters of the central nervous system in patients with T2DM.

## Objectives

1. To analyze biochemical markers of neuronal damage and cognitive performance in patients with T2DM.
2. To assess longitudinal changes under SGLT2i and GLP-1 RA therapy.
3. To compare treatment groups using causal modeling approaches.
4. To explore correlations between laboratory biomarkers and cognitive scales.
5. To evaluate robustness of results after multiple imputation of missing data.

## Study Design and Data Sources

A prospective observational longitudinal cohort study with a 12 month follow-up was conducted in 158 outpatients with type 2 diabetes mellitus attending routine clinical visits. All participants provided written informed consent, and the protocol was approved by the Local Ethics Committee.
Glucose-lowering therapy with SGLT2i or GLP-1 RAs was initiated according to current clinical guidelines. Patients with target glycated hemoglobin (HbA1c) levels underwent a cross sectional assessment, whereas individuals with non target HbA1c levels were followed longitudinally.
Clinical evaluation included physical examination and cognitive testing using the Montreal Cognitive Assessment (MoCA) and the Mini Mental State Examination (MMSE). Laboratory analyses comprised HbA1c and biochemical markers of neuronal damage, including S100 protein, neuron specific enolase, and neurofilament light chains. Measurements were performed at baseline and every three months for up to one year.

### Data Collection
Stored at: `clean_data/diabrain.xlsx`

Measurements were obtained at baseline and after 3, 6, 9 and 12 months:

* Cognitive tests: MoCA, MMSE  
* Laboratory markers: HbA1c, S100 protein, neuron-specific enolase, neurofilament light chains  
* Clinical variables: age, sex, BMI, hypertension, stroke history, kidney function
  
## Statistical Methods

### Descriptive Analysis

* Mean, SD, median, IQR, min, max for continuous variables  
* Frequencies and proportions for categorical variables  

### Modeling Strategy

* Linear regression for baseline comparisons  
* Longitudinal analysis using GEE models  
* G-computation for causal contrasts  
* Counterfactual prediction grids  
* Correlation matrix analysis  

### Missing Data Handling

* Complete case analysis  
* Multiple imputation by chained equations (MICE)

## Software and Versions

All analyses were performed in:

* R 4.5.2  
* tidyverse  
* geepack  
* mice  
* marginaleffects

## Analysis pipeline
*clean_data*: Directory containing data preprocessing code and outputs.

*clean_data.Rmd*: Complete R Markdown notebook with steps for importing, cleaning, handling missing values, and transforming variables from the raw dataset.

*diabrain.rds*: Final, analysis-ready dataset in RDS format (output of clean_data.Rmd). Serves as input for subsequent analysis stages.

*(miss.Rmd)*:
* Data preparation and descriptive statistics: the clean dataset (diabrain.rds) is loaded. Functions generate summary statistics (N, mean, median, SD, IQR) for continuous variables within each treatment group. Descriptive tables for demographics, diabetes characteristics, and baseline clinical markers are produced using gtsummary and formatted with flextable.

* A directed acyclic graph (DAG) is constructed using dagitty and ggdag to explicitly delineate the assumed causal relationships between treatment, neurological outcomes (blood markers NSE, Lchains, S100; cognitive scales MOCA, MMSE), and potential confounders (e.g., Age, Sex, HbA1c, Hypertension, Stroke). 

* Missing data analysis: functions from naniar and mice are used to calculate the proportion of missing values per variable and per observation (miss_var_summary, miss_case_summary). 

* Exploratory longitudinal visualization: the data is transformed to a long format. Spaghetti plots and mean trajectory plots with SEM ribbons are generated using ggplot2 to visualize the raw dynamics of neurological markers (NSE, Lchains, S100), cognitive scores (MOCA, MMSE), and HbA1c over 12 months, stratified by treatment group (GLP1 vs. SGLT2i).

*miss_models, miss_models_Memory, miss_models_MMSE, miss_models_MOCA, miss_models_NSE, miss_models_Lchains* 

* Complete-case analysis: a generalized estimating equations (GEE) model (geeglm from geepack) is fitted on complete cases. The model estimates the association between treatment and longitudinal outcomes, adjusting for pre-specified baseline confounders (Age, Sex, log(DM duration), BMI_0, Hypertension, HbA1c_0, GFR_0, Stroke, Polineuropathy) and their interaction with time.

* Multiple imputation analysis: multiple imputation by chained equations (MICE) is implemented via the mice package. Separate imputation models are specified for the metformin group and the active comparator groups (GLP1/SGLT2i), incorporating all analysis model variables and auxiliary longitudinal outcome measurements to inform the imputation. The GEE model is then fitted on each of the m=10 imputed datasets, and results are pooled using Rubin's rules.

* Counterfactual estimation: for both complete-case and MI analyses, the marginaleffects package is used to compute:

- Adjusted outcome means over time for each active treatment.

- Contrasts (differences) between SGLT2i and GLP1 at each time point.

- Contrasts between each active treatment and the counterfactual metformin baseline. This is achieved by fitting a separate baseline model on the original (or imputed) metformin data and predicting outcomes for the active treatment groups as if they had received metformin, using a standardized covariate distribution.


## Results

### Baseline Data 
The study groups (Metformin, n=44; GLP-1 RAs, n=47; SGLT-2i, n=67) were unbalanced at baseline. Mean (SD) age was 60.5 (8.91), 52.4 (7.66), and 59.7 (9.15) years, respectively, with a female proportion of 68%, 64%, and 58%. Mean (SD) HbA1c was 6.3% (0.40), 7.5% (1.43), and 8.2% (1.10); mean (SD) BMI was 32.4 (4.66), 35.6 (5.63), and 32.6 (4.74) kg/m²; and mean (SD) diabetes duration was 7.1 (7.58), 5.0 (3.38), and 5.8 (5.66) years. This imbalance was accounted for in the subsequent statistical modeling.

### Main variables dynamic
The figure below shows the dynamics of HbA1c levels by visit. As expected, both with SGLT-2 inhibitor therapy and GLP-1 receptor agonist therapy,
a gradual decrease in glycemia was observed.

<img width="572" height="304" alt="Снимок экрана 2026-02-08 в 08 11 28" src="https://github.com/user-attachments/assets/cf61fbd5-6668-4114-829b-6031b277ce4d" />

The figure below shows the dynamics of the MoCA scale by groups and visits.
<img width="577" height="303" alt="Снимок экрана 2026-02-08 в 08 11 56" src="https://github.com/user-attachments/assets/04c9ad2d-1ef5-40e1-932b-1f7077a9a264" />

The figure below shows the dynamics of one of the neuronal damage markers, NSE, by groups and visits.

<img width="576" height="304" alt="Снимок экрана 2026-02-08 в 08 10 17" src="https://github.com/user-attachments/assets/ec6a27c7-e855-4be1-81f1-cd1b5d96dd67" />


### Primary Endpoints

For the primary cognitive endpoints, between group differences in  MoCA and MMSE scores varied across follow-up visits and reached statistical significance
only at selected time points. At 6 and 9 months, the estimated between group difference in MoCA favored SGLT2i therapy (+1.64 points, 95% CI: 0.87− 2.42 and
+3.33 points, 95% CI: 1.67−4.99, respectively); however, no significant difference was observed at 12 months (−0.36 points, 95% CI: −1.29−0.58).
Results remained consistent after multiple imputation and longitudinal modeling.

The figure below shows comparison effects of SGLT2i and GLP1 on MOCA scores after multiple imputation of missing data. 

<img width="519" height="348" alt="Снимок экрана 2026-02-08 в 08 39 42" src="https://github.com/user-attachments/assets/06e14b3a-ef5b-493a-a9ec-2c56290dbdbf" />

### Secondary Endpoints

* No stable treatment specific differences in:
  * Neurofilament light chains
  * S100 protein
  * Neuron-specific enolase
 
The figure below shows comparison effects of SGLT2i and GLP1 on NSE after multiple imputation of missing data. 
<img width="531" height="346" alt="Снимок экрана 2026-02-08 в 08 42 31" src="https://github.com/user-attachments/assets/f66bf0dc-3bfc-41d2-824e-465ee0c35aed" />


## Study Limitations

1. Non-randomized design  
2. Limited sample size  
3. Substantial missing data  
4. Residual confounding  
5. Short follow-up period  
6. Sensitivity to model misspecification  

## Conclusions

* SGLT2 inhibitors and GLP-1 receptor agonists did not demonstrate sustained differential effects on cognitive function over one year.
* No consistent effects were observed for biochemical neuronal damage markers.
* Findings were robust after covariate adjustment and missing data imputation.

## References

* Chen, R., Ovbiagele, B., & Feng, W. (2016). Diabetes and Stroke: Epidemiology, Pathophysiology, Pharmaceuticals and Outcomes. The American journal of the medical sciences, 351(4), 380–386. https://doi.org/10.1016/j.amjms.2016.01.011 
* Cao, F., Yang, F., Li, J., Guo, W., Zhang, C., Gao, F., Sun, X., Zhou, Y., & Zhang, W. (2024). The relationship between diabetes and the dementia risk: a meta-analysis. Diabetology & metabolic syndrome, 16(1), 101. https://doi.org/10.1186/s13098-024-01346-4
* Kostrzewska, P., Kuca, P., Witek, P., Małyszko, J., Madetko Alster, N., & Alster, P. (2025). SGLT-2 Inhibitors in the Prevention and Progression of Neurodegenerative Diseases: A Narrative Review. Neurology and therapy, 14(6), 2295–2312. https://doi.org/10.1007/s40120-025-00832-9
* Schechter, M., Fishkin, A., Mosenzon, O., Sehtman-Shachar, D. R., Cukierman-Yaffe, T., Leibowitz, G., & Aharon-Hananel, G. (2025). Neurodegeneration onset with glucagon-like peptide-1 receptor agonists in people with type 2 diabetes: a real-world multinational cohort study. Cardiovascular diabetology, 24(1), 426. https://doi.org/10.1186/s12933-025-02962-8
* Dedov, I. I., Shestakova, M. V., & Sukhareva, O. Y. (Eds.). (2025). Algorithms of Specialized Medical Care for Patients with Diabetes Mellitus (12th ed.). M.
* Nasreddine, Z. S., Phillips, N. A., Bédirian, V., Charbonneau, S., Whitehead, V., Collin, I., Cummings, J. L., & Chertkow, H. (2005). The Montreal Cognitive Assessment (MoCA): A brief screening tool for mild cognitive impairment. Journal of the American Geriatrics Society, 53(4), 695-699. https://doi.org/10.1111/j.1532-5415.2005.53221.x
* Folstein, M. F., Folstein, S. E., & McHugh, P. R. (1975). Mini-mental state: A practical method for grading the cognitive state of patients for the clinician. Journal of Psychiatric Research, 12(3), 189-198. https://doi.org/10.1016/0022-3956(75)90026-6
* Steiner, J., Bernstein, H. G., Bielau, H., et al. (2007). Evidence for a wide extra-astrocytic distribution of S100B in human brain. BMC Neuroscience, 8, 2. https://doi.org/10.1186/1471-2202-8-2
* Isgrò, M. A., Bottoni, P., & Scatena, R. (2015). Neuron-specific enolase as a biomarker: Biochemical and clinical aspects. Advances in Experimental Medicine and Biology, 867, 125-143. https://doi.org/10.1007/978-94-017-7215-0_9
* Khalil, M., Teunissen, C. E., Otto, M., et al. (2018). Neurofilaments as biomarkers in neurological disorders. Nature Reviews Neurology, 14, 577-589. https://doi.org/10.1038/s41582-018-0058-z
* Snowden, J. M., Rose, S., & Mortimer, K. M. (2011). Implementation of G-computation on a simulated data set: Demonstration of a causal inference technique. American Journal of Epidemiology, 173(7), 731-738. https://doi.org/10.1093/aje/kwq472
* van Buuren, S., & Groothuis-Oudshoorn, K. (2011). mice: Multivariate imputation by chained equations in R. Journal of Statistical Software, 45(3), 1-67. https://doi.org/10.18637/jss.v045.i03
 


