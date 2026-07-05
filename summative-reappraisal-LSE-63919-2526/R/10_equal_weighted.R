# =============================================================================
# 10_equal_weighted.R
# Computes an equal-weighted (state-level average) version of the main
# statewide underperformance estimate.
# Equivalent to make_equal_weighted.do.
#
# The idea: rather than weighting by the number of candidates per state,
# first collapse to state-level averages (one row per state × denier status),
# then compute the mean difference. This gives each state equal weight
# regardless of how many races it had.
# =============================================================================

# ---------------------------------------------------------------------------
# State-level collapse (mean vote share by state and denier status)
# ---------------------------------------------------------------------------
state_level <- statewide |>
  group_by(state, deny) |>
  summarize(voteshare_g = mean(voteshare_g, na.rm = TRUE), .groups = "drop") |>
  pivot_wider(names_from = deny, values_from = voteshare_g,
              names_prefix = "vote_") |>
  rename(vote_non_denier = vote_0, vote_denier = vote_1) |>
  # Keep only states that have both deniers and non-deniers
  filter(!is.na(vote_non_denier), !is.na(vote_denier)) |>
  mutate(diff = vote_denier - vote_non_denier)

# Equal-weighted mean difference (denier minus non-denier)
mean_diff   <- mean(state_level$diff, na.rm = TRUE)
median_diff <- median(state_level$diff, na.rm = TRUE)
n_states    <- nrow(state_level)

message("10_equal_weighted.R: equal-weighted state-level results")
message("  N states with variation: ", n_states)
message("  Mean difference (denier - non-denier): ", round(mean_diff, 4))
message("  Median difference:                     ", round(median_diff, 4))

# Also run a simple FE regression on the collapsed data as a cross-check
# (equivalent to the areg line in the Stata code)
fit_ew <- feols(voteshare_g ~ deny | as.factor(state),
                data = statewide, cluster = ~state)

message("  FE regression deny coef (full data): ",
        round(coef(fit_ew)["deny"], 4),
        " (se = ", round(se(fit_ew)["deny"], 4), ")")

saveRDS(
  list(state_level = state_level,
       mean_diff   = mean_diff,
       fit_ew      = fit_ew),
  file.path(output_dir, "results_equal_weighted.rds")
)
