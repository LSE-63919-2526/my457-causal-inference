# ── 1. NODE DEFINITIONS ─────────────────────────────────────
# Each node: label (line 1), sublabel (line 2), x/y centre, colour role

nodes <- data.frame(
  id       = c("cand_qual", "ideo_ext", "trump_net", "incumbency",
                "state_part", "elec_denial", "pre_funding", "office_type",
                "post_funding", "prim_vote", "endorsements", "voter_pref",
                "vote_share"),

  label    = c("Candidate quality", "Ideological extremism", "Trump network", "Incumbency",
                "State partisanship", "Election denial", "Pre-campaign funding", "Office type",
                "Post-denial funding", "Primary vote share", "Endorsements", "Voter preferences",
                "Vote share (general)"),

  sublabel = c("Experience, funding history", "Pre-election positioning",
                "Recruitment, endorsement", "Pre-treatment by definition",
                "Controlled via FE / pres. vote", "Treatment (2022)",
                "Prior-cycle FEC filings", "GOV, SOS, AG\u2026",
                "Affected by denial status", "Affected by denial",
                "Affected by denial", "Denial aversion mechanism",
                "Outcome"),

  # Canvas coordinates (scaled to match SVG; canvas ~680 wide × 580 tall)
  cx = c(100, 270, 435, 585,
          103, 310, 470, 620,
          130, 290, 435, 580,
          330),
  cy = c(66, 66, 66, 66,
          206, 200, 206, 206,
          346, 346, 346, 346,
          510),

  # Role: "confounder" | "treatment" | "pre_ctrl" | "post_med" | "outcome"
  role = c("confounder", "confounder", "confounder", "confounder",
            "pre_ctrl", "treatment", "pre_ctrl", "pre_ctrl",
            "post_med", "post_med", "post_med", "pre_ctrl",
            "outcome"),
  stringsAsFactors = FALSE
)

# ── 2. COLOUR PALETTES ──────────────────────────────────────
fill_pal <- c(
  confounder = "#FAECED",   # warm red-tint
  treatment  = "#EEEDFE",   # purple-tint
  pre_ctrl   = "#F1EFE8",   # warm grey
  post_med   = "#FAEEDB",   # amber-tint
  outcome    = "#E1F5EE"    # green-tint
)
border_pal <- c(
  confounder = "#993C1D",
  treatment  = "#534AB7",
  pre_ctrl   = "#5F5E5A",
  post_med   = "#854F0B",
  outcome    = "#0F6E56"
)
text_pal <- c(
  confounder = "#711B13",
  treatment  = "#3C3489",
  pre_ctrl   = "#444441",
  post_med   = "#633806",
  outcome    = "#085041"
)
sub_pal <- c(
  confounder = "#993C1D",
  treatment  = "#534AB7",
  pre_ctrl   = "#5F5E5A",
  post_med   = "#854F0B",
  outcome    = "#0F6E56"
)

nodes$fill   <- fill_pal[nodes$role]
nodes$border <- border_pal[nodes$role]
nodes$tcol   <- text_pal[nodes$role]
nodes$scol   <- sub_pal[nodes$role]

# half-widths / half-heights for boxes
nodes$hw <- ifelse(nodes$role %in% c("treatment", "outcome"), 80, 70)
nodes$hh <- ifelse(nodes$role %in% c("treatment", "outcome"), 32, 27)

# ── 3. EDGE DEFINITIONS ─────────────────────────────────────
# edge_type: "confounder_solid" | "confounder_dashed" |
#             "causal_solid"    | "causal_dashed"     |
#             "post_treat"      | "post_treat_dashed" |
#             "pre_ctrl_dashed" | "grey_solid"
edges <- data.frame(
  from = c(
    # confounders → treatment (solid red)
    "cand_qual", "ideo_ext", "trump_net", "incumbency",
    # confounders → outcome (dashed red)
    "cand_qual", "ideo_ext", "trump_net", "incumbency",
    # grey: state_part → election_denial, state_part → vote_share
    "state_part", "state_part",
    # teal dashed: pre_funding → vote_share
    "pre_funding",
    # grey: office_type → vote_share
    "office_type",
    # causal: elec_denial → vote_share (main, solid purple, thick)
    "elec_denial",
    # causal dashed purple: elec_denial → voter_pref (mechanism)
    "elec_denial",
    # amber post-treatment: elec_denial → post_funding, prim_vote, endorsements
    "elec_denial", "elec_denial", "elec_denial",
    # amber: post_funding → vote_share, prim_vote → vote_share (dashed),
    #        endorsements → vote_share, voter_pref → vote_share
    "post_funding", "prim_vote", "endorsements", "voter_pref"
  ),
  to = c(
    "elec_denial", "elec_denial", "elec_denial", "elec_denial",
    "vote_share",  "vote_share",  "vote_share",  "vote_share",
    "elec_denial", "vote_share",
    "vote_share",
    "vote_share",
    "vote_share",
    "voter_pref",
    "post_funding", "prim_vote", "endorsements",
    "vote_share", "vote_share", "vote_share", "vote_share"
  ),
  edge_type = c(
    rep("confounder_solid",  4),
    rep("confounder_dashed", 4),
    "grey_solid", "grey_solid",
    "pre_ctrl_dashed",
    "grey_solid",
    "causal_solid",
    "causal_dashed",
    rep("post_treat", 3),
    "post_treat", "post_treat_dashed", "post_treat", "grey_solid"
  ),
  stringsAsFactors = FALSE
)

edge_colour <- c(
  confounder_solid  = "#D85A30",
  confounder_dashed = "#D85A30",
  causal_solid      = "#534AB7",
  causal_dashed     = "#534AB7",
  post_treat        = "#BA7517",
  post_treat_dashed = "#BA7517",
  pre_ctrl_dashed   = "#1D9E75",
  grey_solid        = "#888780"
)
edge_lty <- c(
  confounder_solid  = "solid",
  confounder_dashed = "dashed",
  causal_solid      = "solid",
  causal_dashed     = "dashed",
  post_treat        = "solid",
  post_treat_dashed = "dashed",
  pre_ctrl_dashed   = "dashed",
  grey_solid        = "solid"
)
edge_size <- c(
  confounder_solid  = 0.8,
  confounder_dashed = 0.8,
  causal_solid      = 1.5,
  causal_dashed     = 1.0,
  post_treat        = 0.7,
  post_treat_dashed = 0.7,
  pre_ctrl_dashed   = 0.8,
  grey_solid        = 0.7
)

edges$colour <- edge_colour[edges$edge_type]
edges$lty    <- edge_lty[edges$edge_type]
edges$size   <- edge_size[edges$edge_type]

# ── 4. MERGE NODE POSITIONS INTO EDGES ──────────────────────
edges <- merge(edges, nodes[, c("id","cx","cy")], by.x = "from", by.y = "id")
names(edges)[names(edges) == "cx"] <- "x0"
names(edges)[names(edges) == "cy"] <- "y0"
edges <- merge(edges, nodes[, c("id","cx","cy")], by.x = "to", by.y = "id")
names(edges)[names(edges) == "cx"] <- "x1"
names(edges)[names(edges) == "cy"] <- "y1"

# ── 5. HELPER: nudge endpoints to box boundaries ────────────
# Simple shrink toward target so arrow doesn't overlap box
nudge_edge <- function(x0, y0, x1, y1, hw0=72, hh0=27, hw1=70, hh1=27) {
  dx <- x1 - x0; dy <- y1 - y0
  d  <- sqrt(dx^2 + dy^2)
  if (d == 0) return(c(x0, y0, x1, y1))
  # clip from source
  t0 <- max(abs(dx)/d * hw0, abs(dy)/d * hh0) / d
  # clip from target
  t1 <- 1 - max(abs(dx)/d * hw1, abs(dy)/d * hh1) / d
  c(x0 + t0*dx, y0 + t0*dy, x0 + t1*dx, y0 + t1*dy)
}

# Apply nudge to each edge (simple straight-line offset; curves drawn via geom_curve)
edges <- within(edges, {
  coords <- mapply(nudge_edge, x0, y0, x1, y1, SIMPLIFY=FALSE)
  x0n <- sapply(coords, `[`, 1)
  y0n <- sapply(coords, `[`, 2)
  x1n <- sapply(coords, `[`, 3)
  y1n <- sapply(coords, `[`, 4)
  rm(coords)
})

# ── 6. PLOT ─────────────────────────────────────────────────
# Flip y (SVG y increases downward; ggplot y increases upward)
# We'll just use scale_y_reverse so raw SVG coords work.

CANVAS_W <- 680
CANVAS_H <- 620

p <- ggplot() +
  coord_fixed(ratio = 1, xlim = c(0, CANVAS_W), ylim = c(0, CANVAS_H),
              expand = FALSE) +
  scale_y_reverse() +

  # ── edges (curves for inter-layer, straight within layer) ──
  geom_curve(
    data = edges,
    aes(x = x0n, y = y0n, xend = x1n, yend = y1n,
        colour = edge_type, linetype = edge_type, linewidth = edge_type),
    curvature = 0.25,
    arrow = arrow(length = unit(6, "pt"), type = "open", ends = "last"),
    show.legend = FALSE
  ) +

  # ── node rectangles ─────────────────────────────────────────
  geom_rect(
    data = nodes,
    aes(xmin = cx - hw, xmax = cx + hw,
        ymin = cy - hh, ymax = cy + hh,
        fill = role),
    colour = NA, show.legend = FALSE
  ) +
  geom_rect(
    data = nodes,
    aes(xmin = cx - hw, xmax = cx + hw,
        ymin = cy - hh, ymax = cy + hh,
        colour = role),
    fill = NA, linewidth = 0.4, show.legend = FALSE
  ) +

  # ── node labels ─────────────────────────────────────────────
  geom_text(
    data = nodes,
    aes(x = cx, y = cy - 8, label = label, colour = role),
    size = 5, fontface = "bold", show.legend = FALSE
  ) +
  geom_text(
    data = nodes,
    aes(x = cx, y = cy + 10, label = sublabel, colour = role),
    size = 3.5, show.legend = FALSE
  ) +

  # ── legend (manual) ─────────────────────────────────────────
  annotate("rect", xmin=30, xmax=650, ymin=552, ymax=610,
           fill=NA, colour="grey80", linewidth=0.4) +
  annotate("segment", x=50, xend=80, y=563, yend=563,
           colour="#D85A30", linewidth=1) +
  annotate("text",  x=86, y=563, label="Confounder path (solid = direct, dashed = to outcome)",
           hjust=0, size=2.5, colour="grey30") +
  annotate("segment", x=50, xend=80, y=580, yend=580,
           colour="#534AB7", linewidth=1.5) +
  annotate("text",  x=86, y=580, label="Causal path (treatment \u2192 outcome)",
           hjust=0, size=2.5, colour="grey30") +
  annotate("segment", x=340, xend=370, y=563, yend=563,
           colour="#BA7517", linewidth=1) +
  annotate("text",  x=376, y=563, label="Post-treatment path (do not control)",
           hjust=0, size=2.5, colour="grey30") +
  annotate("segment", x=340, xend=370, y=580, yend=580,
           colour="#1D9E75", linewidth=1, linetype="dashed") +
  annotate("text",  x=376, y=580, label="Pre-treatment control (safe to include)",
           hjust=0, size=2.5, colour="grey30") +

  # ── title ────────────────────────────────────────────────────
  annotate("text", x = CANVAS_W/2, y = 8,
           label = "DAG: causal structure of election denial and vote share",
           hjust=0.5, vjust=0, size=3.8, fontface="bold", colour="grey20") +

  # ── scales ───────────────────────────────────────────────────
  scale_fill_manual(values = fill_pal) +
  scale_colour_manual(values = c(
    border_pal,
    confounder_solid  = "#D85A30",
    confounder_dashed = "#D85A30",
    causal_solid      = "#534AB7",
    causal_dashed     = "#534AB7",
    post_treat        = "#BA7517",
    post_treat_dashed = "#BA7517",
    pre_ctrl_dashed   = "#1D9E75",
    grey_solid        = "#888780"
  )) +
  scale_linetype_manual(values = c(
    confounder_solid  = "solid",
    confounder_dashed = "dashed",
    causal_solid      = "solid",
    causal_dashed     = "dashed",
    post_treat        = "solid",
    post_treat_dashed = "dashed",
    pre_ctrl_dashed   = "dashed",
    grey_solid        = "solid"
  )) +
  scale_linewidth_manual(values = c(
    confounder_solid  = 0.8,
    confounder_dashed = 0.8,
    causal_solid      = 1.5,
    causal_dashed     = 1.0,
    post_treat        = 0.7,
    post_treat_dashed = 0.7,
    pre_ctrl_dashed   = 0.8,
    grey_solid        = 0.7
  )) +

  theme_void() +
  theme(
    plot.background = element_rect(fill = "white", colour = NA),
    plot.margin     = margin(5, 5, 5, 5)
  )

# ── 7. SAVE ──────────────────────────────────────────────────
ggsave(file.path(output_dir, "election_denial_dag.png"),
       width = 15, height = 10, dpi = 200, bg = "white")

message("Saved: election_denial_dag.png")