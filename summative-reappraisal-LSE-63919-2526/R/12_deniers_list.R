# =============================================================================
# 12_deniers_list.R
# Reproduces the SI appendix tables listing every election-denying candidate
# by office (Tables SI.5-SI.13 in the paper).
# Equivalent to make_deniers_list_table.do.
#
# For each of GOV, SoS, SEN, AG: produces a data frame of all candidates
# classified as a denier by at least one source, with check-mark columns for
# each classification source and the general-election outcome.
# =============================================================================

# ---------------------------------------------------------------------------
# Build a single cleaned base table once, then split by office.
# Using %in% 1 instead of == 1 so that NA values are treated as FALSE
# rather than propagating as NA.
# ---------------------------------------------------------------------------
deniers_base <- deniers_elec |>
  filter(office != "H") |>
  mutate(office = if_else(office == "SOS", "SoS", office)) |>
  filter(deny_538 %in% 1 | deny_su %in% 1 | deny_wapo %in% 1) |>
  mutate(
    general = case_when(
      is.na(voteshare_g) ~ NA_character_,
      w_g == 1           ~ "Won",
      TRUE               ~ "Lost"
    ),
    col_538  = if_else(deny_538  %in% 1 & !is.na(voteshare_g), "\u2713", ""),
    col_sudc = if_else(deny_su   %in% 1, "\u2713", ""),
    col_wapo = if_else(deny_wapo %in% 1 & !is.na(voteshare_g), "\u2713", "")
  ) |>
  select(office, State = state, Candidate = name,
         `General Election` = general,
         `538` = col_538, SUDC = col_sudc, WaPo = col_wapo) |>
  arrange(State, Candidate)

# ---------------------------------------------------------------------------
# Split into one data frame per office
# ---------------------------------------------------------------------------
office_map <- c(GOV = "GOV", SoS = "SoS", SEN = "SEN", AG = "AG")

deniers_tables <- map(names(office_map), function(off) {
  df <- deniers_base |>
    filter(office == off) |>
    select(-office)
  # SUDC does not cover Senate — replace with "-" for that office
  if (off == "SEN") {
    df <- df |> mutate(SUDC = "-")
  }
  df
})

names(deniers_tables) <- names(office_map)

# ---------------------------------------------------------------------------
# Save for use in .qmd
# ---------------------------------------------------------------------------
saveRDS(deniers_tables, file.path(output_dir, "deniers_list_tables.rds"))

message("12_deniers_list.R: denier list tables built for offices: ",
        paste(names(deniers_tables), collapse = ", "))

walk2(names(deniers_tables), deniers_tables, function(nm, tbl) {
  message("  ", nm, ": ", nrow(tbl), " candidates")
})
