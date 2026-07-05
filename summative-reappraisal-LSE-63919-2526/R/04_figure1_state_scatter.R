# =============================================================================
# 04_figure1_state_scatter.R
# Reproduces Figure 1 from Malzahn & Hall (2025).
# Equivalent to make_state_line_graph.do.
#
# For each state that has both election-denying and non-denying Republican
# statewide candidates, plot the average vote share of deniers (x-axis)
# against the average vote share of non-deniers (y-axis).
# Points above the 45-degree line = non-deniers outperform.
# =============================================================================

# ---------------------------------------------------------------------------
# Build the state-level averages dataset
# ---------------------------------------------------------------------------
state_avgs <- statewide |>
  filter(!is.na(voteshare_g)) |>
  group_by(state, deny) |>
  summarize(rep_vote_share = mean(voteshare_g, na.rm = TRUE), .groups = "drop") |>
  pivot_wider(names_from = deny, values_from = rep_vote_share,
              names_prefix = "vote_") |>
  # vote_0 = non-denier avg, vote_1 = denier avg
  rename(non_denier_share = vote_0, denier_share = vote_1) |>
  # Keep only states that have both
  filter(!is.na(non_denier_share), !is.na(denier_share))

# ---------------------------------------------------------------------------
# Plot
# ---------------------------------------------------------------------------
fig1 <- ggplot(state_avgs, aes(x = denier_share, y = non_denier_share)) +
  # Shaded region below 45-degree line (deniers overperform)
  annotate("rect",
           xmin = 0.3, xmax = 0.75, ymin = 0.3, ymax = 0.75,
           fill = "grey80", alpha = 0.3) +
  # 45-degree reference line
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey40") +
  # State points with labels
  geom_point(size = 2) +
  geom_text(aes(label = state), size = 2.5, hjust = -0.15, vjust = 0.5) +
  # Annotation text
  annotate("text", x = 0.60, y = 0.32, label = "Deniers Overperform", size = 3) +
  annotate("text", x = 0.38, y = 0.68, label = "Deniers Underperform", size = 3) +
  # Axes
  scale_x_continuous(limits = c(0.3, 0.75), breaks = seq(0.3, 0.75, 0.1)) +
  scale_y_continuous(limits = c(0.3, 0.75), breaks = seq(0.3, 0.75, 0.1)) +
  coord_equal() +
  labs(
    x = "Denier Vote Share",
    y = "Non-Denier Vote Share"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.background  = element_rect(fill = "white", colour = "white"),
    panel.background = element_rect(fill = "white", colour = "white")
  )

ggsave(file.path(output_dir, "figure1_state_scatter.pdf"),
       plot = fig1, width = 6, height = 6, units = "in")

saveRDS(state_avgs, file.path(output_dir, "state_avgs_fig1.rds"))

message("04_figure1_state_scatter.R: Figure 1 saved.")
