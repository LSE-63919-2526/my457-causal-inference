# =============================================================================
# 13_barplot_incumbency.R
# Reproduces SI Figure SI.2: stacked bar chart showing the number of
# election-denying and non-denying Republican statewide candidates by
# office and incumbency status.
# Equivalent to make_incumbent_statewide_barplot.do.
# =============================================================================

# ---------------------------------------------------------------------------
# Build counts dataset
# ---------------------------------------------------------------------------
barplot_data <- deniers_elec |>
  filter(office != "H") |>
  filter(!is.na(deny), !is.na(inc)) |>
  filter(!is.na(voteshare_g), voteshare_g != 1) |>  # contested general races
  mutate(
    incumbent = factor(if_else(inc == 1, "inc", "non-inc"),
      levels = c("non-inc", "inc")),  # non-inc on bottom, inc on top
    denier    = if_else(deny == 1, "deny", "non-deny"),
    # Ordered factor so offices appear in a consistent sequence
    office    = factor(office, levels = c("AG", "GOV", "SEN", "SOS"))
  ) |>
  count(office, denier, incumbent)

# ---------------------------------------------------------------------------
# Plot — grouped bars within each office, stacked by incumbency
# Matches the Stata `graph bar ... over(incumbent) over(denier) over(office)`
# layout: within each office panel, bars are grouped by denier/non-denier,
# and within each group the bar is split by incumbency.
# ---------------------------------------------------------------------------
fig_si2 <- ggplot(
  barplot_data,
  aes(x = denier, y = n, fill = incumbent)
) +
  geom_col(position = "stack", width = 0.6, colour = "white") +
  facet_wrap(~office, nrow = 1) +
  scale_fill_manual(
    values = c("inc" = "grey60", "non-inc" = "grey90"),
    labels = c("inc" = "Incumbent", "non-inc" = "Non-Incumbent")
  ) +
  scale_x_discrete(labels = c("deny" = "Deny", "non-deny" = "Non-Deny")) +
  labs(
    x    = NULL,
    y    = "Number",
    fill = NULL
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.background  = element_rect(fill = "white", colour = "white"),
    panel.background = element_rect(fill = "white", colour = "white"),
    legend.position  = "right",
    strip.text       = element_text(face = "bold")
  )

ggsave(file.path(output_dir, "figure_si2_barplot_incumbency.pdf"),
       plot = fig_si2, width = 8, height = 4, units = "in")

saveRDS(barplot_data, file.path(output_dir, "barplot_incumbency_data.rds"))

message("13_barplot_incumbency.R: Figure SI.2 saved.")
