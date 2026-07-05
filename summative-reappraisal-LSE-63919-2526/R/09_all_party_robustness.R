# =============================================================================
# 09_all_party_robustness.R
# Reproduces the all-party vote share robustness tables from the appendix.
# Equivalent to make_all_party_robustness_tables.do.
#
# Reruns the main statewide and House analyses using voteshare_g_allparty
# (each candidate's share of all votes cast, not just the two-party total)
# as the outcome. Checks whether results are sensitive to the choice of
# denominator. The statewide FE columns do not restrict to states with
# variation here, matching the simpler areg calls in the original Stata code.
# =============================================================================

# ---------------------------------------------------------------------------
# Statewide all-party data
# ---------------------------------------------------------------------------
statewide_ap <- deniers_elec |>
  filter(office != "H") |>
  filter(!is.na(voteshare_g_allparty)) |>
  filter(voteshare_g_allparty != 1) |>
  mutate(s = as.factor(state))

# ---------------------------------------------------------------------------
# House all-party data
# ---------------------------------------------------------------------------
house_ap <- deniers_elec |>
  filter(office == "H") |>
  filter(!is.na(voteshare_g_allparty)) |>
  mutate(s = as.factor(state))

# ---------------------------------------------------------------------------
# Helper: one regression, returns a tidy tibble row
# ---------------------------------------------------------------------------
run_ap_reg <- function(data, deny_var, outcome = "voteshare_g_allparty",
                        fe = FALSE) {
  if (fe) {
    fml <- as.formula(paste0(outcome, " ~ ", deny_var, " | s"))
  } else {
    fml <- as.formula(paste0(outcome, " ~ ", deny_var, " + pres_voteshare_d"))
  }
  fit <- feols(fml, data = data, cluster = ~state)
  tibble(
    deny_var = deny_var,
    fe       = fe,
    b        = coef(fit)[deny_var],
    se       = se(fit)[deny_var],
    N        = nobs(fit),
    n_states = length(unique(data$state))
  )
}

# ---------------------------------------------------------------------------
# House regressions (cols 1–3, pres vote share control only)
# ---------------------------------------------------------------------------
ap_h1 <- run_ap_reg(house_ap, "deny_538")
ap_h2 <- run_ap_reg(house_ap, "deny_wapo")
ap_h3 <- run_ap_reg(house_ap, "deny")

results_ap_house <- bind_rows(ap_h1, ap_h2, ap_h3) |> mutate(col = 1:3)

# ---------------------------------------------------------------------------
# Statewide regressions (cols 1–4 pres vote share; cols 5–8 state FE)
# Note: the original code uses plain areg on the full dataset for the FE
# columns.
# ---------------------------------------------------------------------------
ap_sw1 <- run_ap_reg(statewide_ap, "deny_su")
ap_sw2 <- run_ap_reg(statewide_ap, "deny_538")
ap_sw3 <- run_ap_reg(statewide_ap, "deny_wapo")
ap_sw4 <- run_ap_reg(statewide_ap, "deny")
ap_sw5 <- run_ap_reg(statewide_ap, "deny_su",   fe = TRUE)
ap_sw6 <- run_ap_reg(statewide_ap, "deny_538",  fe = TRUE)
ap_sw7 <- run_ap_reg(statewide_ap, "deny_wapo", fe = TRUE)
ap_sw8 <- run_ap_reg(statewide_ap, "deny",      fe = TRUE)

results_ap_statewide <- bind_rows(
  ap_sw1, ap_sw2, ap_sw3, ap_sw4,
  ap_sw5, ap_sw6, ap_sw7, ap_sw8
) |> mutate(col = 1:8)

# ---------------------------------------------------------------------------
# Results
# ---------------------------------------------------------------------------
saveRDS(results_ap_house,     file.path(output_dir, "results_allparty_house.rds"))
saveRDS(results_ap_statewide, file.path(output_dir, "results_allparty_statewide.rds"))

message("09_all_party_robustness.R: all-party robustness complete.")
message("  Statewide (col 8 = preferred FE spec): b = ",
        round(results_ap_statewide$b[8], 3),
        "  se = ", round(results_ap_statewide$se[8], 3))
message("  House (col 3 = combined): b = ",
        round(results_ap_house$b[3], 3),
        "  se = ", round(results_ap_house$se[3], 3))
