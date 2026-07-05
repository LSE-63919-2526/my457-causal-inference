# =============================================================================
# 06_primary_analysis.R
# Reproduces SI Table SI.1 (primary election advantage for deniers).
# Equivalent to make_primary_analysis_table.do.
#
# Design: OLS regression of Republican primary vote share on the SUDC
# election-denier indicator, controlling for the number of candidates in
# the race (via fixed effects). Three specifications:
#   Col 1: pres vote share control + number-of-candidates FE
#   Col 2: state FE + number-of-candidates FE
#   Col 3: state × office FE + number-of-candidates FE
# =============================================================================

# ---------------------------------------------------------------------------
# Primary analysis dataset
# ---------------------------------------------------------------------------
primary <- deniers_elec |>
  filter(office != "H") |>    # SUDC does not cover House
  filter(!is.na(voteshare_p)) |>
  group_by(prim_id) |>
  mutate(num_cands = n()) |>
  ungroup() |>
  mutate(
    s          = as.factor(state),
    o          = as.factor(office),
    s_o        = as.factor(paste(state, office, sep = "_")),
    num_cands_f = as.factor(num_cands)   # FE for number of candidates
  )

# ---------------------------------------------------------------------------
# Column 1: pres vote share + num_cands FE
# feols absorbs num_cands_f as a fixed effect while keeping pres_voteshare_d
# as a regular covariate (equivalent to Stata's i.num_cands + pres_voteshare_d)
# ---------------------------------------------------------------------------
p_col1 <- feols(
  voteshare_p ~ deny_su + pres_voteshare_d | num_cands_f,
  data    = primary,
  cluster = ~state
)

# ---------------------------------------------------------------------------
# Column 2: state FE + num_cands FE  (equivalent to reghdfe ... a(s num_cands))
# ---------------------------------------------------------------------------
p_col2 <- feols(
  voteshare_p ~ deny_su | s + num_cands_f,
  data    = primary,
  cluster = ~state
)

# ---------------------------------------------------------------------------
# Column 3: state × office FE + num_cands FE
# ---------------------------------------------------------------------------
p_col3 <- feols(
  voteshare_p ~ deny_su | s_o + num_cands_f,
  data    = primary,
  cluster = ~state
)

# ---------------------------------------------------------------------------
# Results
# ---------------------------------------------------------------------------
extract_primary <- function(fit, col) {
  tibble(
    col      = col,
    b        = coef(fit)["deny_su"],
    se       = se(fit)["deny_su"],
    N        = nobs(fit),
    n_states = length(unique(primary$state[!is.na(primary$voteshare_p)]))
  )
}

results_primary <- bind_rows(
  extract_primary(p_col1, 1),
  extract_primary(p_col2, 2),
  extract_primary(p_col3, 3)
)

# ---------------------------------------------------------------------------
# Format SI Table SI.1
# ---------------------------------------------------------------------------
table_primary <- tibble(
  ` ` = c("Election-Denying Candidate", " ", "N", "No. of States",
          "Pres. Vote Share", "No. of Candidates FEs",
          "State FE", "State × Office FE"),
  `(1)` = c(
    sprintf("%.3f", results_primary$b[1]),
    sprintf("(%.3f)", results_primary$se[1]),
    as.character(results_primary$N[1]),
    as.character(results_primary$n_states[1]),
    "Yes", "Yes", "No", "No"
  ),
  `(2)` = c(
    sprintf("%.3f", results_primary$b[2]),
    sprintf("(%.3f)", results_primary$se[2]),
    as.character(results_primary$N[2]),
    as.character(results_primary$n_states[2]),
    "No", "Yes", "Yes", "No"
  ),
  `(3)` = c(
    sprintf("%.3f", results_primary$b[3]),
    sprintf("(%.3f)", results_primary$se[3]),
    as.character(results_primary$N[3]),
    as.character(results_primary$n_states[3]),
    "No", "Yes", "No", "Yes"
  )
)

saveRDS(results_primary, file.path(output_dir, "results_primary.rds"))
saveRDS(table_primary,   file.path(output_dir, "table_primary_formatted.rds"))

message("06_primary_analysis.R: Primary table complete.")
print(table_primary)
