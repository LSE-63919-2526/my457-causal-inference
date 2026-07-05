# =============================================================================
# 03_table2_house_general.R
# Reproduces Table 2 from Malzahn & Hall (2025).
# Equivalent to make_general_house_table.do.
#
# Design: OLS regression of Republican two-party vote share on an
# election-denier indicator with district-level presidential vote share
# as a control. Standard errors clustered by state.
# =============================================================================

# ---------------------------------------------------------------------------
# Helper: run a single House regression and return a tidy summary tibble.
# ---------------------------------------------------------------------------
run_house_reg <- function(data, deny_var) {
  fml <- as.formula(paste0("voteshare_g ~ ", deny_var, " + pres_voteshare_d"))
  fit <- feols(fml, data = data, cluster = ~state)

  tibble(
    deny_var = deny_var,
    b        = coef(fit)[deny_var],
    se       = se(fit)[deny_var],
    N        = nobs(fit),
    n_states = length(unique(data$state))
  )
}

# ---------------------------------------------------------------------------
# Run columns (538, WaPo, Combined)
# ---------------------------------------------------------------------------
h_col1 <- run_house_reg(house, "deny_538")
h_col2 <- run_house_reg(house, "deny_wapo")
h_col3 <- run_house_reg(house, "deny")

results_t2 <- bind_rows(h_col1, h_col2, h_col3) |>
  mutate(col = 1:3)

# ---------------------------------------------------------------------------
# Format Table 2
# ---------------------------------------------------------------------------
table2 <- tibble(
  ` ` = c("Election-Denying Candidate", " ", "N", "Pres. Vote Share"),
  `(1) 538` = c(
    sprintf("%.3f", results_t2$b[1]),
    sprintf("(%.3f)", results_t2$se[1]),
    as.character(results_t2$N[1]),
    "Yes"
  ),
  `(2) WaPo` = c(
    sprintf("%.3f", results_t2$b[2]),
    sprintf("(%.3f)", results_t2$se[2]),
    as.character(results_t2$N[2]),
    "Yes"
  ),
  `(3) Combined` = c(
    sprintf("%.3f", results_t2$b[3]),
    sprintf("(%.3f)", results_t2$se[3]),
    as.character(results_t2$N[3]),
    "Yes"
  )
)

saveRDS(results_t2, file.path(output_dir, "results_table2.rds"))
saveRDS(table2,     file.path(output_dir, "table2_formatted.rds"))

message("03_table2_house_general.R: Table 2 complete.")
print(table2)
