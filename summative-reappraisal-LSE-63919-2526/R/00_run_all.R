# =============================================================================
# 00_run_all.R
# Master script: sources all analysis files in order.
# Mirrors the structure of election_deniers_master.do.
#
# Working directory: Root of the replication repo, here:
# the folder that contains Data_Modified/, Output/, and R/.
#
# Required packages:
#   install.packages(c("tidyverse", "haven", "fixest", "knitr", "kableExtra"))
# =============================================================================

# ---------------------------------------------------------------------------
# 0. Shared setup: paths, packages, data
# ---------------------------------------------------------------------------
source("R/01_load_data.R")

# ---------------------------------------------------------------------------
# 1. Main analyses
# ---------------------------------------------------------------------------
source("R/02_table1_statewide_general.R")     # Table 1  (statewide general)
source("R/03_table2_house_general.R")          # Table 2  (House general)
source("R/04_figure1_state_scatter.R")         # Figure 1 (state scatter)
source("R/05_incumbency_coef_plot.R")          # Figure SI.1 + SI Table SI.15
source("R/06_primary_analysis.R")              # SI Table SI.1 (primary)

# ---------------------------------------------------------------------------
# 2. Robustness / appendix analyses
# ---------------------------------------------------------------------------
source("R/07_538_robustness.R")                # SI Table SI.2 (538 coding robust)
source("R/08_congress_statewide_difference.R") # statewide vs congress test
source("R/09_all_party_robustness.R")          # all-party vote share robustness
source("R/10_equal_weighted.R")                # equal-weighted state-level diff
source("R/11_confusion_table.R")               # SI confusion table (538 vs SUDC)
source("R/12_deniers_list.R")                  # SI tables: list of deniers
source("R/13_barplot_incumbency.R")            # SI barplot: deniers by office/inc

message("\n=== All scripts completed successfully ===")
