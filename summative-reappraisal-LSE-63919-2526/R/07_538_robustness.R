# =============================================================================
# 07_538_robustness.R
# Reproduces SI Table SI.2: robustness to alternative 538 denier definitions.
# Equivalent to make_538_general_robust.do.
#
# Four alternative 538 classifications:
#   deny_538_1 (= deny_538): only "Fully denied" (baseline)
#   deny_538_2: "Fully denied" OR "No comment" OR "Avoided answering"
#   deny_538_3: "Fully denied" OR "Raised questions"
#   deny_538_4: "Fully denied" only, but drops "No comment"/"Avoided"
# Each is run with pres vote share (cols 1–4) and state FE (cols 5–8).
# =============================================================================

# ---------------------------------------------------------------------------
# Build alternative denier indicators from 'stance' variable
# ---------------------------------------------------------------------------
statewide_rob <- statewide |>
  mutate(
    deny_538_1 = as.integer(stance == "Fully denied"),
    deny_538_2 = as.integer(stance %in% c("Fully denied", "No comment",
                                           "Avoided answering")),
    deny_538_3 = as.integer(stance %in% c("Fully denied", "Raised questions")),
    # deny_538_4: same as deny_538_1 but treat "No comment"/"Avoided" as NA
    deny_538_4 = case_when(
      stance == "Fully denied"                           ~ 1L,
      stance %in% c("No comment", "Avoided answering")  ~ NA_integer_,
      TRUE                                               ~ 0L
    )
  )

# Helper reusing the same pattern as 02_table1
run_rob_reg <- function(data, deny_var, fe = FALSE) {
  data_clean <- data |> filter(!is.na(.data[[deny_var]]))
  if (fe) {
    # restrict to states with variation
    data_clean <- data_clean |>
      group_by(state) |>
      mutate(d_sum = sum(.data[[deny_var]], na.rm = TRUE),
             d_tot = sum(!is.na(.data[[deny_var]]))) |>
      ungroup() |>
      filter(d_sum != d_tot, d_sum != 0)
    fml <- as.formula(paste0("voteshare_g ~ ", deny_var, " | s"))
  } else {
    fml <- as.formula(paste0("voteshare_g ~ ", deny_var, " + pres_voteshare_d"))
  }
  fit <- feols(fml, data = data_clean, cluster = ~state)
  tibble(
    deny_var = deny_var,
    fe       = fe,
    b        = coef(fit)[deny_var],
    se       = se(fit)[deny_var],
    N        = nobs(fit),
    n_states = length(unique(data_clean$state))
  )
}

deny_vars <- c("deny_538_1", "deny_538_2", "deny_538_3", "deny_538_4")

rob_pres <- map_dfr(deny_vars, ~run_rob_reg(statewide_rob, .x, fe = FALSE))
rob_fe   <- map_dfr(deny_vars, ~run_rob_reg(statewide_rob, .x, fe = TRUE))

results_rob <- bind_rows(rob_pres, rob_fe) |>
  mutate(col = 1:8)

saveRDS(results_rob, file.path(output_dir, "results_538_robustness.rds"))

message("07_538_robustness.R: SI Table SI.2 complete.")
print(results_rob |> select(col, deny_var, fe, b, se, N, n_states))
