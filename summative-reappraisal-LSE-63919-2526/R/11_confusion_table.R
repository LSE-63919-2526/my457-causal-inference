# =============================================================================
# 11_confusion_table.R
# Reproduces the SI confusion (cross-tabulation) table comparing the 538
# and States United (SUDC) election-denier classifications.
# Equivalent to make_538_su_confusion_table.do.
#
# Restricted to Republican candidates for AG, GOV, and SOS (the three offices
# covered by both datasets) who appeared in the general election.
# =============================================================================

# ---------------------------------------------------------------------------
# Subset the relevant observations
# ---------------------------------------------------------------------------
confusion_data <- deniers_elec |>
  filter(office %in% c("AG", "GOV", "SOS")) |>
  filter(!is.na(voteshare_g)) |>
  # Both indicators must be non-missing to be helpful
  filter(!is.na(deny_538), !is.na(deny_su)) |>
  mutate(
    deny_538_label = if_else(deny_538 == 1, "Denies", "Accepts"),
    deny_su_label  = if_else(deny_su  == 1, "Denies", "Accepts")
  )

# ---------------------------------------------------------------------------
# Cross-tabulation
# ---------------------------------------------------------------------------
confusion_matrix <- confusion_data |>
  count(deny_538_label, deny_su_label) |>
  pivot_wider(names_from = deny_su_label, values_from = n, values_fill = 0) |>
  rename(`538 Stance` = deny_538_label)

message("11_confusion_table.R: 538 vs SUDC confusion table")
print(confusion_matrix)

# ---------------------------------------------------------------------------
# Named cell values for inline reporting (mirrors Stata scalars)
# ---------------------------------------------------------------------------
cell <- function(row538, col_su) {
  confusion_data |>
    filter(deny_538_label == row538, deny_su_label == col_su) |>
    nrow()
}

accept_accept <- cell("Accepts", "Accepts")
accept_deny   <- cell("Accepts", "Denies")   # 538 accepts, SUDC denies
deny_accept   <- cell("Denies",  "Accepts")  # 538 denies,  SUDC accepts
deny_deny     <- cell("Denies",  "Denies")

message(sprintf(
  "  Accept/Accept: %d  |  Accept(538)/Deny(SU): %d  |  Deny(538)/Accept(SU): %d  |  Deny/Deny: %d",
  accept_accept, accept_deny, deny_accept, deny_deny
))

saveRDS(
  list(confusion_matrix = confusion_matrix,
       accept_accept = accept_accept,
       accept_deny   = accept_deny,
       deny_accept   = deny_accept,
       deny_deny     = deny_deny),
  file.path(output_dir, "results_confusion_table.rds")
)
