# MY457 Summative Reappraisal

**Course:** MY457 — Causal Inference for Observational and Experimental Studies  
**Term:** WT 2026  
**Due:** 22 May 2026  
**Author:** 63919

---

## Paper Being Reappraised

Malzahn, S., & Hall, A. B. (2025). Election-Denying Republican Candidates Underperformed in the 2022 Midterms. *American Political Science Review*, 119(1), 1–9. https://doi.org/10.1017/S0003055424000200

The paper asks whether Republican candidates who publicly denied the result of the 2020 presidential election underperformed in the 2022 midterms compared to Republicans who did not. Using OLS regression with controls for state-level partisanship and state fixed effects, the authors estimate a penalty of roughly 2–4 percentage points across statewide races (Senate, Governor, Attorney General, Secretary of State), with no detectable effect in U.S. House races. Denier classification draws on three independent sources: FiveThirtyEight (538), the States United Democracy Center (SUDC), and the Washington Post (WaPo), combined into a union measure.

---

## Repository Structure

```
.
├── reappraisal.qmd              # Main report (Quarto; renders to self-contained HTML)
├── README.md                    # This file
├── data/
│   └── Data_Modified/
│       ├── deniers_elec.dta     # Pre-processed dataset from the authors' pipeline
│       ├── trump_endorsements.csv  # Hand-collected Trump 2022 endorsements (see below)
│       └── prior_office.csv        # Hand-collected prior office data (see below)
├── R/                           # Standalone R translation of the authors' Stata scripts
│   ├── 00_run_all.R
│   ├── 01_...R
│   └── 13_barplot_incumbency.R
└── Output/                      # Figures and tables written by scripts (auto-created)
```

The full analysis is self-contained in `reappraisal.qmd`. The `R/` scripts are a standalone translation of the authors' original Stata replication package and can be run independently via `00_run_all.R`.

---

## Data

The analysis requires one processed dataset from the authors' replication package plus two hand-collected CSV files produced for this reappraisal. All files must be placed exactly as shown in the repository structure above for the code to run without modification.

### Required files

| File | Location in repo | Source |
|---|---|---|
| `deniers_elec.dta` | `data/Data_Modified/deniers_elec.dta` | Authors' replication package (see below) |
| `trump_endorsements.csv` | `data/Data_Modified/trump_endorsements.csv` | Hand-collected (included in repo) |
| `prior_office.csv` | `data/Data_Modified/prior_office.csv` | Hand-collected (included in repo) |

### `deniers_elec.dta`

This is the pre-processed analysis dataset produced by the authors' data cleaning pipeline. It is available directly from the APSR Dataverse replication package:

> Malzahn, Janet, and Andrew B. Hall. 2024. "Replication Data for:
> Election-Denying Republican Candidates Underperformed in the 2022
> Midterms." Harvard Dataverse. https://doi.org/10.7910/DVN/JPKJSJ

Download `deniers_elec.dta` from that page and place it at `data/Data_Modified/deniers_elec.dta`. Create the `Data_Modified/` subdirectory inside `data/` if it does not already exist.

### `trump_endorsements.csv` — hand-collected, included in repo

This file records whether Donald Trump issued a formal endorsement for each of the 116 Republican statewide general election candidates in the analysis sample. It was hand-coded for the original contribution in Section 5 of this reappraisal.

**Coding rule.** `trump_endorsed` is coded 1 if Trump issued a formal Save America PAC endorsement for a candidate's 2022 race, and 0 otherwise. Verbal rally mentions without a formal PAC statement are coded 0. Ron DeSantis (FL, GOV) is the principal edge case: Trump made a verbal mention at a rally the evening before the November 2022 general election but never issued a formal PAC endorsement; he is coded 0.

**Sources.** The primary source is the Ballotpedia endorsements page:

> https://ballotpedia.org/Endorsements_by_Donald_Trump#2022

This was cross-checked against the Washington Post 2022 endorsement tracker for any candidates where the Ballotpedia record was ambiguous. All 116 candidates in the statewide general election sample receive a valid code; no imputation is required. The 64 non-denier candidates not appearing in the SI appendix were verified as absent from the Ballotpedia 2022 endorsements page and coded 0.

**Columns.**

| Column | Type | Description |
|---|---|---|
| `candidate` | string | Candidate name in `LASTNAME FIRSTNAME` format |
| `state` | string | Two-letter state abbreviation |
| `office` | string | Office code: `AG`, `GOV`, `SEN`, or `SOS` |
| `general_election` | string | Election outcome: `Won` or `Lost` |
| `trump_endorsed` | integer | 1 = formal Trump PAC endorsement; 0 = no endorsement |

### `prior_office.csv` — hand-collected, included in repo

This file records whether each of the 116 Republican statewide general election candidates had previously held any elected office before their 2022 race. It was hand-coded for the original contribution in Section 5 of this reappraisal.

**Coding rule.** `prior_office` is coded 1 if the candidate had previously held any elected office at any level (federal, statewide, or state legislature) before their 2022 race, and 0 otherwise. Appointed positions and non-electoral public roles are not counted. County-level elected offices (e.g. county attorney, county clerk) are coded 0 to maintain a consistent threshold across candidates; only offices within Ballotpedia's standard electoral scope are counted. All 116 candidates in the statewide general election sample receive a valid code.

**Source.** Ballotpedia individual candidate pages, accessed May 2026:

> https://ballotpedia.org/[Candidate_Name]

**Columns.**

| Column | Type | Description |
|---|---|---|
| `candidate` | string | Candidate name in `LASTNAME FIRSTNAME` format |
| `state` | string | Two-letter state abbreviation |
| `office` | string | Office code: `AG`, `GOV`, `SEN`, or `SOS` |
| `inc` | integer | Incumbency indicator from `deniers_elec` (included for reference) |
| `deny` | integer | Denial indicator from combined measure (included for reference) |
| `prior_office` | integer | 1 = previously held elected office; 0 = no prior office |

### Other files in the replication package

The full replication package also contains raw data files and Stata cleaning scripts in `data/Code/` and `data/Data_Raw/`. These are not required to reproduce this reappraisal but are available from the same Dataverse link above. To reconstruct `deniers_elec.dta` from scratch, run `data/Code/election_deniers_master.do` in Stata after placing all raw files in `data/Data_Raw/`.

---

## Replication Package

The original replication data and Stata code are available from the APSR Dataverse at the DOI above. This project starts from `deniers_elec.dta`, the pre-processed analysis dataset produced by the authors' cleaning pipeline, rather than translating the full raw-data pipeline.

---

## Software and Dependencies

**R** (≥ 4.3.0) with the following packages:

| Package | Purpose |
|---|---|
| `tidyverse` | Data manipulation and `ggplot2` figures |
| `haven` | Reading `.dta` files |
| `fixest` | OLS and fixed-effects estimation with clustered SEs (`feols`) |
| `knitr` / `kableExtra` | Table formatting in the report |

Install all dependencies with:

```r
install.packages(c("tidyverse", "haven", "fixest", "knitr", "kableExtra"))
```

Render the report with:

```r
quarto::quarto_render("reappraisal.qmd")
```

---

## Contents of the Report

The report is structured in five sections plus a code appendix.

**Section 1 — Research Design and Identification Strategy.** Summarises the authors' estimating equation, the three denier classification sources, and the key conditional independence assumption.

**Section 2 — Computational Reproduction.** Reproduces the main published results in R using `fixest::feols()` in place of Stata's `areg`/`reghdfe`. Covers Table 1 (statewide underperformance), Table 2 (House races), the statewide vs. House interaction test, and Figure 1 (state-level scatter plot). Two places where the R translation is more internally consistent than the original Stata are noted: (a) `num_cands` is computed after filtering to candidates with observed vote shares, and (b) the within-state variation subsetting for the state-FE columns uses the correct non-missing count.

**Section 3 — Appendix Reproduction and Causal Structure.** Reproduces SI Figure SI.1 (incumbency coefficient plot by office) and SI Table SI.15 (the primary-election analysis). Includes a directed acyclic graph (DAG) making the causal structure and identification constraints explicit, motivating the pre-treatment covariate collection in Section 5.

**Section 4 — Critical Evaluation.** Covers seven issues: selection on observables and omitted variable bias; why state fixed effects do not resolve within-state selection; post-treatment bias from candidate-level controls; SUTVA and spillover testing; measurement assumptions and false negatives; small-sample concerns; and heterogeneity by state competitiveness.

**Section 5 — Original Contribution.** Collects three pre-treatment covariates — Trump endorsement status, incumbency, and prior office held — hand-coded from Ballotpedia for all 116 statewide general election candidates. Tests whether the denial coefficient is stable when they are controlled for, and runs a placebo test using the 2020 presidential vote share as an outcome. The denial coefficient attenuates by 59% when all three controls are added and loses statistical significance. Prior office held shows near-zero imbalance between deniers and non-deniers and contributes negligibly to the attenuation; incumbency and Trump endorsement drive the result. The placebo test coefficient is near zero and insignificant, showing the denial indicator is not a mechanical proxy for state-level partisanship.

---

## Key Findings of the Reappraisal

The computational reproduction closely matches the published estimates. The two divergences identified in the code audit are methodological improvements rather than errors and have no material effect on the results.

The critical evaluation finds that the association between denial and underperformance is robust across denier sources, specifications, and office types, but the design cannot distinguish voter aversion to election denial from selection of weaker candidates into denial. The original contribution collects pre-treatment data on Trump network access, incumbency, and prior electoral experience for all 116 candidates and shows that controlling for these variables absorbs 59% of the reported denial penalty, with the residual coefficient losing statistical significance. The operative confounders are institutional embeddedness (incumbency) and partisan network alignment (Trump endorsement), not raw prior experience. A placebo test on the 2020 presidential vote share is consistent with modest residual confounding but provides no evidence of mechanical state-level partisanship driving the main result.