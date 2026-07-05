# =============================================================================
# 08_congress_statewide_difference.R
# Tests whether the election-denying penalty is significantly larger for
# statewide offices than for congressional (House + Senate) races.
# Equivalent to check_congress_statewide_difference.do.
#
# Two versions:
#   statewide  = SOS, AG, GOV only (excludes Senate)
#   statewide2 = SOS, AG, GOV, SEN (includes Senate)
# The interaction term deny_538 × statewide captures the differential penalty.
# =============================================================================

all_races <- deniers_elec |>
  filter(!is.na(voteshare_g), voteshare_g != 1) |>
  mutate(
    statewide  = as.integer(office %in% c("SOS", "AG", "GOV")),
    statewide2 = as.integer(office %in% c("SOS", "AG", "GOV", "SEN")),
    s          = as.factor(state)
  )

# Model 1: statewide = SOS/AG/GOV vs House + Senate
fit_sw1 <- feols(
  voteshare_g ~ deny_538 * statewide + pres_voteshare_d,
  data    = all_races,
  cluster = ~state
)

# Model 2: statewide2 = SOS/AG/GOV/SEN vs House only
fit_sw2 <- feols(
  voteshare_g ~ deny_538 * statewide2 + pres_voteshare_d,
  data    = all_races,
  cluster = ~state
)

# Display results
message("08_congress_statewide_difference.R: results below.")
message("\n--- Model 1: statewide = SOS/AG/GOV ---")
print(summary(fit_sw1))

message("\n--- Model 2: statewide2 = SOS/AG/GOV/SEN ---")
print(summary(fit_sw2))

saveRDS(list(fit_sw1 = fit_sw1, fit_sw2 = fit_sw2),
        file.path(output_dir, "results_congress_statewide_diff.rds"))
