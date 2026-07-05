# =============================================================================
# 02_table1_statewide_general.R
# Reproduces Table 1 (and SI Table SI.3) from Malzahn & Hall (2025).
# Equivalent to make_general_statewide_table.do.
#
# Design: OLS regression of Republican two-party vote share on an
# election-denier indicator, using either:
#   - Columns 1–4: presidential vote share as a continuous control
#   - Columns 5–8: state fixed effects (restricting to states with variation
#                  in the denier classification within the state)
# Standard errors are clustered by state throughout.
# =============================================================================

# ---------------------------------------------------------------------------
# Helper: run a single regression and return a tidy one-row summary tibble.
# 'data'    : data frame
# 'deny_var': name of the election-denier indicator (character)
# 'fe'      : logical — TRUE = state FE (feols), FALSE = pres vote share control
# ---------------------------------------------------------------------------
run_statewide_reg <- function(data, deny_var, fe = FALSE) {

  if (fe) {
    # State fixed effects: use feols() from fixest.
    # The ~~ syntax absorbs the fixed effect; cluster = ~state gives
    # clustered SEs equivalent to Stata's areg ... absorb(s) cluster(state).
    fml <- as.formula(paste0("voteshare_g ~ ", deny_var, " | s"))
    fit <- feols(fml, data = data, cluster = ~state)
  } else {
    # Presidential vote share control: plain OLS with clustered SEs.
    fml <- as.formula(paste0("voteshare_g ~ ", deny_var, " + pres_voteshare_d"))
    fit <- feols(fml, data = data, cluster = ~state)
  }

  coef_row  <- coef(fit)[deny_var]
  se_row    <- se(fit)[deny_var]
  n_obs     <- nobs(fit)
  n_states  <- length(unique(data$state))

  tibble(
    deny_var = deny_var,
    fe       = fe,
    b        = coef_row,
    se       = se_row,
    N        = n_obs,
    n_states = n_states
  )
}

# ---------------------------------------------------------------------------
# Helper: for the state-FE columns, restrict to states that have both
# deniers and non-deniers for the relevant classification variable.
# Mirrors the Stata preserve/restore blocks in the original code.
# ---------------------------------------------------------------------------
subset_with_variation <- function(data, deny_var) {
  data |>
    group_by(state) |>
    mutate(
      deny_sum = sum(.data[[deny_var]], na.rm = TRUE),
      deny_tot = sum(!is.na(.data[[deny_var]]))
    ) |>
    ungroup() |>
    filter(deny_sum != deny_tot, deny_sum != 0)
}

# ---------------------------------------------------------------------------
# Run all columns
# ---------------------------------------------------------------------------

# Columns 1–4: pres vote share control, all available states
col1 <- run_statewide_reg(statewide, "deny_su",   fe = FALSE)
col2 <- run_statewide_reg(statewide, "deny_538",  fe = FALSE)
col3 <- run_statewide_reg(statewide, "deny_wapo", fe = FALSE)
col4 <- run_statewide_reg(statewide, "deny",      fe = FALSE)

# Columns 5–8: state fixed effects, restricted to states with variation
col5 <- run_statewide_reg(subset_with_variation(statewide, "deny_su"),   "deny_su",   fe = TRUE)
col6 <- run_statewide_reg(subset_with_variation(statewide, "deny_538"),  "deny_538",  fe = TRUE)
col7 <- run_statewide_reg(subset_with_variation(statewide, "deny_wapo"), "deny_wapo", fe = TRUE)
col8 <- run_statewide_reg(subset_with_variation(statewide, "deny"),      "deny",      fe = TRUE)

results_t1 <- bind_rows(col1, col2, col3, col4, col5, col6, col7, col8) |>
  mutate(col = 1:8)

# ---------------------------------------------------------------------------
# Format and display Table 1
# ---------------------------------------------------------------------------
table1 <- tibble(
  ` ` = c("Election-Denying Candidate", " ", "N", "No. of States",
           "Pres. Vote Share", "State FEs"),
  `(1) States United` = c(
    sprintf("%.3f", results_t1$b[1]),
    sprintf("(%.3f)", results_t1$se[1]),
    as.character(results_t1$N[1]),
    as.character(results_t1$n_states[1]),
    "Yes", "No"
  ),
  `(2) 538` = c(
    sprintf("%.3f", results_t1$b[2]),
    sprintf("(%.3f)", results_t1$se[2]),
    as.character(results_t1$N[2]),
    as.character(results_t1$n_states[2]),
    "Yes", "No"
  ),
  `(3) WaPo` = c(
    sprintf("%.3f", results_t1$b[3]),
    sprintf("(%.3f)", results_t1$se[3]),
    as.character(results_t1$N[3]),
    as.character(results_t1$n_states[3]),
    "Yes", "No"
  ),
  `(4) Combined` = c(
    sprintf("%.3f", results_t1$b[4]),
    sprintf("(%.3f)", results_t1$se[4]),
    as.character(results_t1$N[4]),
    as.character(results_t1$n_states[4]),
    "Yes", "No"
  ),
  `(5) States United` = c(
    sprintf("%.3f", results_t1$b[5]),
    sprintf("(%.3f)", results_t1$se[5]),
    as.character(results_t1$N[5]),
    as.character(results_t1$n_states[5]),
    "No", "Yes"
  ),
  `(6) 538` = c(
    sprintf("%.3f", results_t1$b[6]),
    sprintf("(%.3f)", results_t1$se[6]),
    as.character(results_t1$N[6]),
    as.character(results_t1$n_states[6]),
    "No", "Yes"
  ),
  `(7) WaPo` = c(
    sprintf("%.3f", results_t1$b[7]),
    sprintf("(%.3f)", results_t1$se[7]),
    as.character(results_t1$N[7]),
    as.character(results_t1$n_states[7]),
    "No", "Yes"
  ),
  `(8) Combined` = c(
    sprintf("%.3f", results_t1$b[8]),
    sprintf("(%.3f)", results_t1$se[8]),
    as.character(results_t1$N[8]),
    as.character(results_t1$n_states[8]),
    "No", "Yes"
  )
)

# Save results object for use in .qmd
saveRDS(results_t1, file.path(output_dir, "results_table1.rds"))
saveRDS(table1,     file.path(output_dir, "table1_formatted.rds"))

message("02_table1_statewide_general.R: Table 1 complete.")
print(table1)
