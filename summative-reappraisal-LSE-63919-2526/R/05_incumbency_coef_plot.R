# =============================================================================
# 05_incumbency_coef_plot.R
# Reproduces SI Figure SI.1 and SI Table SI.15 from Malzahn & Hall (2025).
# Equivalent to make_incumbency_tables_and_plots.do + make_incumbency_coef_plot.R.
#
# For each office (GOV, SOS, AG, SEN, H), runs:
#   (a) deny × inc interaction model → extract non-incumbent effect (deny coef)
#       and incumbent effect (deny + deny×inc via linear combination)
#   (b) pooled model (deny only, no interaction) → pooled coefficient
# Coefficients and 95% CIs are then plotted as a dot-and-whisker chart.
# =============================================================================

offices <- c("GOV", "SOS", "AG", "SEN", "H")

# ---------------------------------------------------------------------------
# Helper: extract one row of results from a fitted feols model.
# 'fit'          : feols model object
# 'term'         : coefficient name to extract
# 'is_lincom'    : if TRUE, compute deny + deny:inc (incumbent effect)
# 'lincom_terms' : character vector of terms to sum for the linear combination
# ---------------------------------------------------------------------------
extract_coef <- function(fit, term = NULL, is_lincom = FALSE,
                         lincom_terms = NULL) {
  if (!is_lincom) {
    b   <- as.numeric(coef(fit)[term])
    ci  <- confint(fit, level = 0.95)     # matrix: rows = terms, cols = lo/hi
    lower <- as.numeric(ci[term, 1])
    upper <- as.numeric(ci[term, 2])
  } else {
    # Keep only actually estimated terms
    lincom_terms <- intersect(lincom_terms, names(coef(fit)))
    coefs  <- coef(fit)[lincom_terms]
    b      <- as.numeric(sum(coefs, na.rm = TRUE))
    # Var(sum) = 1'V1 where V is the sub-vcov for the relevant terms
    vcv    <- vcov(fit)[lincom_terms, lincom_terms, drop = FALSE]
    se_lc  <- sqrt(as.numeric(sum(vcv, na.rm = TRUE)))
    lower  <- b - 1.96 * se_lc
    upper  <- b + 1.96 * se_lc
  }
  tibble(b = b, lower = lower, upper = upper)
}

# ---------------------------------------------------------------------------
# Run models for each office
# ---------------------------------------------------------------------------
coef_rows <- list()

for (off in offices) {

  df_off <- deniers_elec |>
    filter(office == off) |>
    filter(!is.na(voteshare_g), voteshare_g != 1) |>
    mutate(s = as.factor(state))

  # ---- interaction model (deny × inc) ----
  fit_int <- tryCatch(
    feols(voteshare_g ~ deny * inc + pres_voteshare_d,
          data = df_off, cluster = ~state),
    error = function(e) NULL
  )

  if (!is.null(fit_int) && "deny" %in% names(coef(fit_int))) {

    # Non-incumbent effect (deny coefficient when inc = 0)
    row_noninc <- extract_coef(fit_int, "deny") |>
      mutate(office = off, inc = 0)

    # Incumbent effect (deny + deny:inc) — only if interaction term exists
    if ("deny:inc" %in% names(coef(fit_int))) {
      row_inc <- extract_coef(fit_int,
                               is_lincom  = TRUE,
                               lincom_terms = c("deny", "deny:inc")) |>
        mutate(office = off, inc = 1)
    } else {
      row_inc <- tibble(b = NA_real_, lower = NA_real_, upper = NA_real_,
                        office = off, inc = 1)
    }
  } else {
    row_noninc <- tibble(b = NA_real_, lower = NA_real_, upper = NA_real_,
                         office = off, inc = 0)
    row_inc    <- tibble(b = NA_real_, lower = NA_real_, upper = NA_real_,
                         office = off, inc = 1)
  }

  # ---- pooled model (deny only) ----
  fit_pool <- tryCatch(
    feols(voteshare_g ~ deny + pres_voteshare_d,
          data = df_off, cluster = ~state),
    error = function(e) NULL
  )

  if (!is.null(fit_pool) && "deny" %in% names(coef(fit_pool))) {
    row_pool <- extract_coef(fit_pool, "deny") |>
      mutate(office = off, inc = 2)   # inc = 2 flags "pooled"
  } else {
    row_pool <- tibble(b = NA_real_, lower = NA_real_, upper = NA_real_,
                       office = off, inc = 2)
  }

  coef_rows <- c(coef_rows, list(row_noninc, row_inc, row_pool))
}

coef_df <- bind_rows(coef_rows) |>
  # SOS has no denying incumbents — blank those out as in original
  mutate(
    b     = if_else(office == "SOS" & inc == 1, NA_real_, b),
    lower = if_else(office == "SOS" & inc == 1, NA_real_, lower),
    upper = if_else(office == "SOS" & inc == 1, NA_real_, upper)
  ) |>
  mutate(
  inc_label = factor(
    case_when(
      inc == 0 ~ "Non-Incumbents",
      inc == 1 ~ "Incumbents",
      inc == 2 ~ "Pooled"
    ),
    levels = c("Non-Incumbents", "Incumbents", "Pooled")  # top to bottom within each row
  ),
  office = factor(office, levels = c("AG", "GOV", "H", "SEN", "SOS"))
  )

# ---------------------------------------------------------------------------
# Plot (SI Figure SI.1)
# ---------------------------------------------------------------------------
fig_si1 <- ggplot(
  coef_df,
  aes(x = b, y = office,
      shape = inc_label, linetype = inc_label,
      group = inc_label)
) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey50") +
  geom_point(
    position = position_dodge(width = 0.5),
    size     = 2.5,
    na.rm    = TRUE
  ) +
  geom_errorbar(
  aes(xmin = lower, xmax = upper),
  position  = position_dodge(width = 0.5),
  width     = 0.2,
  na.rm     = TRUE,
  orientation = "y"
  ) +
  scale_shape_manual(
    values = c("Non-Incumbents" = 16, "Incumbents" = 17, "Pooled" = 15),
    guide  = guide_legend(reverse = TRUE)
  ) +
  scale_linetype_manual(
    values = c("Non-Incumbents" = "dashed", "Incumbents" = "twodash", "Pooled" = "solid"),
    guide  = guide_legend(reverse = TRUE)
  ) +
  scale_x_continuous(limits = c(-0.12, 0.12)) +
  labs(
    x        = "Deny Coefficient",
    y        = "Office",
    shape    = "",
    linetype = ""
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.background  = element_rect(fill = "white", colour = "white"),
    panel.background = element_rect(fill = "white", colour = "white"),
    legend.position  = "right"
  )

ggsave(file.path(output_dir, "figure_si1_incumbency_coef_plot.pdf"),
       plot = fig_si1, width = 7, height = 5, units = "in")

# Also save the SI Table SI.15 data
saveRDS(coef_df, file.path(output_dir, "incumbency_coef_data.rds"))

# Write CSV for reference
write_csv(coef_df, file.path(output_dir, "incumbency_coef_plot.csv"))

message("05_incumbency_coef_plot.R: Figure SI.1 saved.")