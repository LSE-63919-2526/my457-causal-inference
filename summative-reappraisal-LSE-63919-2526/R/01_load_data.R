# =============================================================================
# 01_load_data.R
# Loads the pre-processed deniers_elec dataset (equivalent to the Stata
# deniers_elec.dta produced by create_deniers_elec.do) and attaches the
# packages used throughout the analysis.
#
# The replication package's Data_Modified/deniers_elec.dta is the
# starting point for all analysis scripts; the raw-data cleaning pipeline
# (create_statewide_general_elec.do, create_house_general_elec.do,
# merge_538_su_wapo_elec.do) relies on a Stata-only name-parsing package
# (extrname) and a custom megamerge command, so it is not translated here.
# =============================================================================

library(tidyverse)   
library(haven)       # read_dta() for Stata files
library(fixest)      # feols() — clustered SEs, fixed effects (equivalent to areg/reghdfe)
library(sandwich)    # for vcovCL
library(lmtest)      # coeftest() for clustered SEs on plain lm models
library(knitr)       # kable() for tables in the .qmd
library(kableExtra)  # extra table formatting

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
data_dir   <- "data/Data_Modified"
output_dir <- "Output"
dir.create(output_dir, showWarnings = FALSE)

# ---------------------------------------------------------------------------
# Load data
# ---------------------------------------------------------------------------
deniers_elec <- read_dta(file.path(data_dir, "deniers_elec.dta"))

# ---------------------------------------------------------------------------
# Shared data preparation used by multiple analysis scripts
# ---------------------------------------------------------------------------

# Subset used by all statewide general-election analyses (Tables 1, SI.3, etc.)
statewide <- deniers_elec |>
  filter(office != "H") |>                 # drop House
  filter(!is.na(voteshare_g)) |>           # nonmissing general votes
  filter(voteshare_g != 1) |>              # drop uncontested races
  mutate(
    s = as.factor(state),                 
    o = as.factor(office)                  
  )

# Subset used by House general-election analyses (Table 2)
house <- deniers_elec |>
  filter(office == "H") |>
  filter(!is.na(voteshare_g)) |>
  filter(voteshare_g != 1) |>
  mutate(s = as.factor(state))

message("01_load_data.R: data loaded successfully.")
message("  statewide rows: ", nrow(statewide))
message("  house rows:     ", nrow(house))
