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

* Design: Prospective observational longitudinal cohort study  
* Duration: 12 months  
* Participants: Outpatients with T2DM  
* Therapy groups: Metformin, SGLT2 inhibitors, GLP-1 receptor agonists  
* Ethics: Approved by the local ethics committee, written informed consent obtained  

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

## Results

### Primary Endpoints

* No sustained difference between SGLT2i and GLP-1 RA groups in MoCA or MMSE scores over 12 months.
* Transient MoCA differences were observed at months 6 and 9, favoring SGLT2i, but disappeared by month 12.
  <img width="668" height="668" alt="image" src="https://github.com/user-attachments/assets/3144664b-2122-4e88-ac6e-cae18a2452de" />
* Results remained consistent after multiple imputation and longitudinal modeling.

### Secondary Endpoints

* No stable treatment specific differences in:
  * Neurofilament light chains
  * S100 protein
  * Neuron-specific enolase
* Correlations between cognitive scores and neuronal injury markers were detected but did not differ systematically between treatment groups.


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

Key references include:

* Chen et al., 2016. Diabetes and Stroke  
* Cao et al., 2024. Diabetes and dementia meta-analysis  
* Kostrzewska et al., 2025. SGLT2 inhibitors and neurodegeneration  
* Schechter et al., 2025. GLP-1 RA real-world study  
* Nasreddine et al., 2005. MoCA  
* Folstein et al., 1975. MMSE  
* van Buuren and Groothuis-Oudshoorn, 2011. mice  


