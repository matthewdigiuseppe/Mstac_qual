# theme_qualstack.R — QualStack figure conventions as code.
# Bundled with QualStack (/qualstack:viz). Copy into the paper as
# code/theme_qualstack.R and source() it from code/06-figures.R, so the
# replication package is self-contained. Needs ggplot2 (>= 3.4.0); the model
# helpers also need CausalQueries; ggraph is optional (the DAG falls back to
# plain ggplot2 without it). Rules behind the choices: figure-conventions.md.
#
#   qs_colors, qs_palette        role colors and a <= 4-series palette, colorblind-safe
#                                and distinct in grayscale
#   theme_qualstack()            the ggplot theme; scale_color_qualstack(), scale_fill_qualstack()
#   qs_plot_dag()                the DAG, left to right in time: arrows, "+"/"-" where a
#                                restriction fixes an effect's sign, <-> as dashed arcs
#   qs_dag_data(), qs_dag_layout(), qs_restrictions()   the DAG's data and the restriction table
#   qs_plot_prior_posterior()    prior against posterior for one or more queries
#                                (from the updated model, or from queries.csv)
#   qs_plot_evidence_path()      the case query after each clue, in the order sought
#                                (qs_trace_case or qs_informal_trace output)
#   qs_plot_clue_learning()      expected learning by clue (qs_clue_table) or strategy
#                                (qs_strategy_table)
#   qs_plot_frontier()           two-step clue strategies (qs_two_step): expected cost
#                                against expected variance, undominated frontier highlighted
#   qs_plot_case_strategies()    expected posterior variance by case-selection strategy
#                                (qs_case_strategies)
#   qs_plot_sensitivity()        the answer under each model variant (qs_sensitivity), base
#                                model highlighted
#   qs_read_chronology(), qs_parse_dates(), qs_plot_timeline()
#                                case chronology at the precision of each date
#   qs_read_md_table()           a table from a memo (e.g. an informal running posterior)
#   qs_save()                    <name>.pdf + <name>.png + <name>-data.csv
#
# Every qs_plot_*() returns a ggplot whose $data is the plotted data (draws,
# summaries, events), so qs_save(fig, "fig-2-posterior") writes the CSV that
# rebuilds the figure. The exception is qs_plot_dag() on the plot_model engine:
# pass data = qs_dag_data(model). Titles are left to the caller: the title
# states the claim (labs(title = ...)); the caption each helper writes is the
# key to its encodings.

library(ggplot2)
stopifnot("theme_qualstack.R needs ggplot2 >= 3.4.0" = utils::packageVersion("ggplot2") >= "3.4.0")

# ---- palette and theme --------------------------------------------------------------

# Colors carry roles, and each role keeps its own gray level in black-and-white
# print (approximate gray value, 0-255, in brackets). Roles shown together also
# differ in line type, shape, or fill, so no figure depends on hue alone.
# Dark blue, rose and ochre are Paul Tol's "high-contrast" scheme.
qs_colors <- c(
  ink       = "#222222",  # [ 34] text, nodes, arrows
  posterior = "#004488",  # [ 69] the posterior, the answer, the evidence path
  accent    = "#BB5566",  # [118] the highlighted choice: base model, frontier, chosen strategy
  third     = "#DDAA33",  # [178] a third series
  prior     = "#8C8C8C",  # [140] the prior: always dashed or hollow
  muted     = "#BDBDBD"   # [189] context: dominated strategies, reference lines
)
qs_palette <- unname(qs_colors[c("posterior", "accent", "third", "ink")])

# grid: which major gridlines to keep ("both", "x" = vertical lines only, "y", "none").
theme_qualstack <- function(base_size = 11, base_family = "",
                            grid = c("both", "x", "y", "none")) {
  grid <- match.arg(grid)
  th <- theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      plot.title            = element_text(face = "bold", size = rel(1.1)),
      plot.subtitle         = element_text(color = "grey30", size = rel(0.9)),
      plot.caption          = element_text(color = "grey40", size = rel(0.75), hjust = 0),
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      plot.background       = element_rect(fill = "white", color = NA),
      panel.grid.minor      = element_blank(),
      panel.grid.major      = element_line(color = "grey88", linewidth = 0.3),
      axis.title            = element_text(size = rel(0.9)),
      axis.text             = element_text(color = "grey20"),
      legend.position       = "bottom",
      legend.title          = element_blank(),
      strip.text            = element_text(face = "bold", hjust = 0)
    )
  if (grid %in% c("x", "none")) th <- th + theme(panel.grid.major.y = element_blank())
  if (grid %in% c("y", "none")) th <- th + theme(panel.grid.major.x = element_blank())
  th
}

scale_color_qualstack <- function(...) scale_color_manual(values = qs_palette, ...)
scale_fill_qualstack  <- function(...) scale_fill_manual(values = qs_palette, ...)

# ---- saving ---------------------------------------------------------------------------

# qs_save(fig_2_posterior, "fig-2-posterior", width = 6.5, height = 3.5)
# Writes <dir>/<name>.pdf (vector, for the manuscript), .png (raster, for
# slides), and <name>-data.csv (the plotted data). The directory defaults to
# getOption("qs.fig_dir"), which 06-figures.R sets to here("output", "figures").
qs_save <- function(plot, name, data = NULL, width = 6.5, height = 4, dpi = 300,
                    dir = getOption("qs.fig_dir", file.path("output", "figures"))) {
  if (is.null(data)) data <- .qs_plot_data(plot)
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  files <- file.path(dir, paste0(name, c(".pdf", ".png", "-data.csv")))
  pdf_device <- if (isTRUE(capabilities("cairo"))) grDevices::cairo_pdf else grDevices::pdf
  ggsave(files[1], plot, width = width, height = height, units = "in", device = pdf_device)
  ggsave(files[2], plot, width = width, height = height, units = "in", dpi = dpi, bg = "white")
  utils::write.csv(data, files[3], row.names = FALSE)
  message("qs_save: ", paste(basename(files), collapse = ", "))
  invisible(files)
}

.qs_plot_data <- function(plot) {
  d <- plot$data
  if (!is.data.frame(d) || ".ggraph.orig_index" %in% names(d))
    stop("qs_save(): the plot's data is not a plain data frame; pass the plotted data as ",
         "data = ... (for a DAG drawn by plot_model(), data = qs_dag_data(model))", call. = FALSE)
  d <- as.data.frame(d)
  d[, !vapply(d, is.list, logical(1)), drop = FALSE]
}

.qs_num <- function(x, digits = 2) formatC(x, format = "f", digits = digits)
.qs_pct <- function(x) paste0(round(100 * x), "%")
.qs_wrap <- function(..., width = 90) paste(unlist(lapply(c(...), strwrap, width = width)), collapse = "\n")
.qs_first_col <- function(d, candidates) {
  hit <- intersect(candidates, names(d))
  if (length(hit)) hit[1] else NA_character_
}
# The column that splits a design table into case types (clue-select stacks one
# table per case type), when it has more than one value.
.qs_panel_col <- function(d, candidates = c("case_type", "given", "cell")) {
  hit <- Filter(function(cl) cl %in% names(d) && length(unique(d[[cl]])) > 1, candidates)
  if (length(hit)) hit[[1]] else NA_character_
}
.qs_need <- function(d, cols, fn) {
  miss <- setdiff(cols, names(d))
  if (length(miss)) stop(fn, "(): missing column(s) ", paste(miss, collapse = ", "), call. = FALSE)
}

# ---- the DAG ---------------------------------------------------------------------------

.qs_parents <- function(s) {
  ps <- trimws(strsplit(as.character(s), ",")[[1]])
  ps[!is.na(ps) & nzchar(ps)]
}

.qs_dag_edges <- function(model) {
  pd <- CausalQueries::grab(model, "parents_df")
  out <- data.frame(from = character(0), to = character(0), type = character(0))
  for (i in seq_len(nrow(pd))) {
    ps <- .qs_parents(pd$parent_nodes[i])
    if (length(ps)) out <- rbind(out, data.frame(from = ps, to = as.character(pd$node[i]), type = "->"))
  }
  stmt <- as.character(CausalQueries::grab(model, "statement"))
  pairs <- regmatches(stmt, gregexpr("[A-Za-z0-9_.]+\\s*<->\\s*[A-Za-z0-9_.]+", stmt))[[1]]
  for (pair in pairs) {
    ab <- trimws(strsplit(pair, "<->")[[1]])
    out <- rbind(out, data.frame(from = ab[1], to = ab[2], type = "<->"))
  }
  unique(out)
}

# Which of a node's nodal types let parent j (1-based, in parents_df order)
# raise or lower it. Digit i (0-based) of a type is the node's value when the
# parents take the bits of i, the first parent varying fastest.
.qs_effects <- function(types, j) {
  if (!length(types)) return(list(pos = logical(0), neg = logical(0)))
  m <- do.call(rbind, strsplit(types, ""))
  step <- 2^(j - 1)
  lo_idx <- which(bitwAnd(seq_len(ncol(m)) - 1L, as.integer(step)) == 0)
  lo <- m[, lo_idx, drop = FALSE] == "1"
  hi <- m[, lo_idx + step, drop = FALSE] == "1"
  list(pos = rowSums(!lo & hi) > 0, neg = rowSums(lo & !hi) > 0)
}

.qs_sign <- function(types, j) {
  e <- .qs_effects(types, j)
  if (!any(e$pos) && !any(e$neg)) return("0")
  if (!any(e$neg)) return("+")
  if (!any(e$pos)) return("-")
  ""
}

# One row per node: its parents, nodal types kept of those possible, the sign
# each parent's effect is restricted to ("+": no negative effect remains), and
# whether those signs account for every removed type (FALSE = further
# restrictions, which the caption or an appendix table must state).
qs_restrictions <- function(model) {
  pd <- CausalQueries::grab(model, "parents_df")
  kept <- CausalQueries::grab(model, "nodal_types")
  removed <- attr(model, "restrictions")
  rows <- lapply(seq_len(nrow(pd)), function(i) {
    v <- as.character(pd$node[i])
    ps <- .qs_parents(pd$parent_nodes[i])
    k <- length(ps)
    types <- as.character(kept[[v]])
    signs <- if (k) vapply(seq_len(k), function(j) .qs_sign(types, j), character(1)) else character(0)
    only_signs <- if (k == 0) {
      length(types) == 2
    } else if (k <= 4) {
      n <- 2^k
      all_types <- apply(as.matrix(expand.grid(rep(list(0:1), n))), 1, paste, collapse = "")
      ok <- rep(TRUE, length(all_types))
      for (j in seq_len(k)) {
        e <- .qs_effects(all_types, j)
        if (signs[j] %in% c("+", "0")) ok <- ok & !e$neg
        if (signs[j] %in% c("-", "0")) ok <- ok & !e$pos
      }
      sum(ok) == length(types)
    } else NA
    data.frame(
      node = v, parents = paste(ps, collapse = ", "),
      types_kept = length(types), types_possible = 2^(2^k),
      signs = if (any(nzchar(signs))) paste0(ps[nzchar(signs)], ": ", signs[nzchar(signs)],
                                             collapse = "; ") else "",
      only_signs = only_signs,
      removed = paste(as.character(removed[[v]]), collapse = "; "),
      kept = if (length(types) <= 16) paste(types, collapse = "; ") else paste(length(types), "types")
    )
  })
  do.call(rbind, rows)
}

.qs_edge_signs <- function(model) {
  r <- qs_restrictions(model)
  out <- data.frame(from = character(0), to = character(0), sign = character(0))
  for (i in seq_len(nrow(r))) {
    if (!nzchar(r$signs[i])) next
    s <- strsplit(strsplit(r$signs[i], "; ")[[1]], ": ")
    out <- rbind(out, data.frame(from = vapply(s, `[`, "", 1), to = r$node[i],
                                 sign = vapply(s, `[`, "", 2)))
  }
  out
}

# Left to right in time: x is the node's generation (longest path from a root)
# times dx; y follows the parents, and a node that sits on a longer arrow is
# moved off it. x and y (in grab(model, "nodes") order, or named) override.
qs_dag_layout <- function(model, x = NULL, y = NULL, dx = 1.5, gap = 0.45, bump = 0.6) {
  nodes <- as.character(CausalQueries::grab(model, "nodes"))
  pd <- CausalQueries::grab(model, "parents_df")
  pa <- setNames(lapply(pd$parent_nodes, .qs_parents), as.character(pd$node))[nodes]
  gen <- setNames(rep(0L, length(nodes)), nodes)
  for (pass in seq_along(nodes)) for (v in nodes)
    if (length(pa[[v]])) gen[v] <- 1L + max(gen[pa[[v]]])
  yy <- setNames(numeric(length(nodes)), nodes)
  for (g in sort(unique(gen))) {
    vs <- nodes[gen == g]
    target <- if (g == 0) (length(vs) + 1) / 2 - seq_along(vs) else
      vapply(vs, function(v) mean(yy[pa[[v]]]), numeric(1))
    o <- order(-target, match(vs, nodes))
    vs <- vs[o]; target <- target[o]
    pos <- target
    for (i in seq_along(pos)[-1]) pos[i] <- min(pos[i], pos[i - 1] - 1)
    yy[vs] <- pos + (mean(target) - mean(pos))
  }
  if (is.null(y)) {
    ed <- .qs_dag_edges(model)
    for (pass in 1:10) {
      moved <- FALSE
      for (e in seq_len(nrow(ed))) {
        a <- ed$from[e]; b <- ed$to[e]
        if (abs(gen[b] - gen[a]) < 2) next
        for (cn in nodes[gen > min(gen[a], gen[b]) & gen < max(gen[a], gen[b])]) {
          yl <- yy[a] + (gen[cn] - gen[a]) / (gen[b] - gen[a]) * (yy[b] - yy[a])
          if (abs(yy[cn] - yl) < gap) {
            up <- yy[cn] >= yl
            same <- nodes[gen == gen[cn]]
            side <- same[if (up) yy[same] >= yy[cn] else yy[same] <= yy[cn]]
            yy[side] <- yy[side] + (yl + (if (up) bump else -bump) - yy[cn])
            moved <- TRUE
          }
        }
      }
      if (!moved) break
    }
  }
  xx <- gen * dx
  pick <- function(v, def) {
    if (is.null(v)) return(def)
    if (!is.null(names(v))) { def[names(v)] <- v; return(def) }
    stopifnot("x and y need one value per node" = length(v) == length(nodes))
    setNames(v, nodes)
  }
  data.frame(node = nodes, x = unname(pick(x, xx)), y = unname(pick(y, yy)), gen = unname(gen))
}

# The DAG as one long data frame (what qs_save() writes for a DAG figure):
# element = node | edge | confound; for edges, sign is the restricted sign and
# curvature is nonzero where a straight arrow would cross another node.
qs_dag_data <- function(model, x = NULL, y = NULL, labels = NULL) {
  lay <- qs_dag_layout(model, x = x, y = y)
  nodes <- lay$node
  P <- setNames(lapply(seq_len(nrow(lay)), function(i) c(lay$x[i], lay$y[i])), nodes)
  sub <- setNames(rep(NA_character_, length(nodes)), nodes)
  if (!is.null(labels)) {
    if (is.null(names(labels))) names(labels) <- nodes
    sub[names(labels)] <- labels
  }
  ed <- .qs_dag_edges(model)
  sg <- .qs_edge_signs(model)
  key <- paste(sg$from, sg$to)
  # cross product of (b - a) and (c - a): > 0 when c lies left of the travel direction
  side_of <- function(a, b, c) (b[1] - a[1]) * (c[2] - a[2]) - (b[2] - a[2]) * (c[1] - a[1])
  dist_seg <- function(a, b, c) {
    ab <- b - a; t <- max(0, min(1, sum((c - a) * ab) / sum(ab^2)))
    sqrt(sum((a + t * ab - c)^2))
  }
  curv <- vapply(seq_len(nrow(ed)), function(e) {
    a <- P[[ed$from[e]]]; b <- P[[ed$to[e]]]
    others <- setdiff(nodes, c(ed$from[e], ed$to[e]))
    if (ed$type[e] == "<->") {
      # bend away from the other nodes; with none on either side, bend up
      s <- sum(vapply(others, function(cn) sign(side_of(a, b, P[[cn]])) /
                        (1 + dist_seg(a, b, P[[cn]])), numeric(1)))
      up_is_left <- b[1] >= a[1]
      if (s == 0) return(if (up_is_left) -0.45 else 0.45)
      return(if (s > 0) 0.45 else -0.45)
    }
    hit <- others[vapply(others, function(cn) dist_seg(a, b, P[[cn]]) < 0.3, logical(1))]
    if (!length(hit)) return(0)
    if (side_of(a, b, P[[hit[1]]]) > 0) 0.35 else -0.35
  }, numeric(1))
  node_rows <- data.frame(element = "node", from = nodes, to = NA_character_,
                          x = lay$x, y = lay$y, xend = NA_real_, yend = NA_real_,
                          sign = NA_character_, curvature = NA_real_, label = unname(sub[nodes]))
  edge_rows <- data.frame(element = ifelse(ed$type == "<->", "confound", "edge"),
                          from = ed$from, to = ed$to,
                          x = vapply(ed$from, function(v) P[[v]][1], 0),
                          y = vapply(ed$from, function(v) P[[v]][2], 0),
                          xend = vapply(ed$to, function(v) P[[v]][1], 0),
                          yend = vapply(ed$to, function(v) P[[v]][2], 0),
                          sign = ifelse(ed$type == "->", sg$sign[match(paste(ed$from, ed$to), key)], NA),
                          curvature = curv, label = NA_character_)
  out <- rbind(node_rows, edge_rows)
  rownames(out) <- NULL
  out
}

# Endpoints on the node circles, and the point midway along the drawn edge.
# geom_curve() bends left of travel for negative curvature, right for
# positive, with its midpoint 0.97 * |curvature| * half the chord off the
# chord; a curve leaves the chord at about 2 * atan(0.97 * |curvature|), so its
# endpoints are rotated that far around each circle and it meets them square.
.qs_edge_geometry <- function(d, r) {
  if (!nrow(d)) return(cbind(d, x0 = numeric(0), y0 = numeric(0), x1 = numeric(0),
                             y1 = numeric(0), xm = numeric(0), ym = numeric(0)))
  dx <- d$xend - d$x; dy <- d$yend - d$y; L <- sqrt(dx^2 + dy^2)
  ux <- dx / L; uy <- dy / L                       # along the chord
  nx <- -uy; ny <- ux                              # left of travel
  cv <- ifelse(is.na(d$curvature), 0, d$curvature)
  side <- -sign(cv)                                # +1: the curve bulges left of travel
  ca <- cos(2 * atan(0.97 * abs(cv))); sa <- sin(2 * atan(0.97 * abs(cv))) * side
  r1 <- r + 0.03                                   # room for the arrowhead's tip
  d$x0 <- d$x + r * (ca * ux + sa * nx); d$y0 <- d$y + r * (ca * uy + sa * ny)
  d$x1 <- d$xend + r1 * (-ca * ux + sa * nx); d$y1 <- d$yend + r1 * (-ca * uy + sa * ny)
  off <- side * 0.97 * abs(cv) * sqrt((d$x1 - d$x0)^2 + (d$y1 - d$y0)^2) / 2
  d$xm <- (d$x0 + d$x1) / 2 + off * nx
  d$ym <- (d$y0 + d$y1) / 2 + off * ny
  d
}

.qs_dag_caption <- function(model, dd, width = 64) {
  r <- qs_restrictions(model)
  parts <- "Arrow: a possible direct effect; a missing arrow rules one out."
  if (any(dd$sign %in% c("+", "-", "0"), na.rm = TRUE))
    parts <- c(parts, "+ (-): the restrictions rule out negative (positive) effects along that arrow.")
  if (any(dd$element == "confound"))
    parts <- c(parts, "Dashed arc: unobserved confounding.")
  extra <- r[!is.na(r$only_signs) & !r$only_signs, , drop = FALSE]
  unknown <- r[is.na(r$only_signs) & r$types_kept < r$types_possible, , drop = FALSE]
  if (nrow(extra) || nrow(unknown))
    parts <- c(parts, paste0("Further restrictions: ",
                             paste(c(sprintf("%s keeps %d of %g nodal types", extra$node,
                                             extra$types_kept, extra$types_possible),
                                     sprintf("%s (see the restriction table)", unknown$node)),
                                   collapse = "; "), "."))
  paste(strwrap(paste(parts, collapse = " "), width), collapse = "\n")
}

# qs_plot_dag(model): left to right in time; labels = c(I = "Inequality", ...)
# adds descriptive labels under the node names; highlight = nodes drawn filled
# (e.g. the clues sought in cases). engine "auto" uses CausalQueries::plot_model()
# when ggraph is installed, else draws the same layout with ggplot2 alone.
qs_plot_dag <- function(model, x = NULL, y = NULL, labels = NULL, highlight = NULL,
                        signs = TRUE, caption = TRUE, r = 0.22,
                        engine = c("auto", "plot_model", "ggplot")) {
  engine <- match.arg(engine)
  if (engine == "auto")
    engine <- if (requireNamespace("ggraph", quietly = TRUE)) "plot_model" else "ggplot"
  if (engine == "plot_model" && !requireNamespace("ggraph", quietly = TRUE))
    stop("engine = \"plot_model\" needs the ggraph package; use engine = \"ggplot\"", call. = FALSE)
  dd <- qs_dag_data(model, x = x, y = y, labels = labels)
  nd <- dd[dd$element == "node", ]
  ink <- qs_colors[["ink"]]
  hl <- nd$from %in% highlight
  tsize <- ifelse(nchar(nd$from) <= 2, 4.2, pmax(2.2, 4.2 * 2 / nchar(nd$from)))
  badge_data <- function(d) {
    e <- .qs_edge_geometry(d[d$element == "edge" & d$sign %in% c("+", "-", "0"), ], r)
    if (!signs) e <- e[0, ]
    e
  }
  if (engine == "plot_model") {
    # plot_model() bends every <-> arc the same way (positive strength = left of
    # travel); take the side most arcs need to clear the other nodes.
    cf <- dd$curvature[dd$element == "confound"]
    strength <- if (length(cf) && sum(sign(cf)) > 0) -0.3 else 0.3
    p <- CausalQueries::plot_model(model, x_coord = nd$x, y_coord = nd$y,
                                   nodecol = ink, textcol = ifelse(hl, "white", ink),
                                   shape = ifelse(hl, 16, 21), nodesize = 12,
                                   textsize = tsize, strength = strength) +
      coord_fixed(clip = "off") +
      scale_x_continuous(expand = expansion(add = 0.45)) +
      scale_y_continuous(expand = expansion(add = 0.55))
    edges_for_badges <- dd
    edges_for_badges$curvature[edges_for_badges$element == "edge"] <- 0  # plot_model draws straight arrows
    b <- badge_data(edges_for_badges)
    if (nrow(b)) p <- p +
      geom_point(data = b, aes(x = xm, y = ym), inherit.aes = FALSE, color = "white", size = 4.5) +
      geom_text(data = b, aes(x = xm, y = ym, label = sign), inherit.aes = FALSE,
                color = ink, size = 4, fontface = "bold")
    lab <- nd[!is.na(nd$label), ]
    # nodes here are sized in mm, so the label is offset in text lines, not data units
    if (nrow(lab)) p <- p + geom_text(data = lab, aes(x = x, y = y, label = label), inherit.aes = FALSE,
                                      vjust = 3.6, size = 3, color = "grey30", lineheight = 0.9)
  } else {
    circles <- function(d) {
      d <- d[d$element == "node", ]
      t <- seq(0, 2 * pi, length.out = 61)
      do.call(rbind, lapply(seq_len(nrow(d)), function(i)
        data.frame(node = d$from[i], x = d$x[i] + r * cos(t), y = d$y[i] + r * sin(t),
                   filled = d$from[i] %in% highlight)))
    }
    straight <- function(d) .qs_edge_geometry(d[d$element == "edge" & d$curvature == 0, ], r)
    curved <- function(cv, el) function(d) .qs_edge_geometry(d[d$element == el & d$curvature == cv, ], r)
    arrow_head <- grid::arrow(length = grid::unit(2.4, "mm"), angle = 22, type = "closed")
    p <- ggplot(dd) +
      geom_polygon(data = circles, aes(x = x, y = y, group = node, fill = filled),
                   color = ink, linewidth = 0.5) +
      scale_fill_manual(values = c(`TRUE` = ink, `FALSE` = "white"), guide = "none") +
      geom_segment(data = straight, aes(x = x0, y = y0, xend = x1, yend = y1),
                   color = ink, linewidth = 0.5, arrow = arrow_head, arrow.fill = ink)
    for (cv in setdiff(unique(dd$curvature[dd$element == "edge"]), 0))
      p <- p + geom_curve(data = curved(cv, "edge"), aes(x = x0, y = y0, xend = x1, yend = y1),
                          curvature = cv, color = ink, linewidth = 0.5, arrow = arrow_head,
                          arrow.fill = ink)
    for (cv in unique(dd$curvature[dd$element == "confound"]))
      p <- p + geom_curve(data = curved(cv, "confound"), aes(x = x0, y = y0, xend = x1, yend = y1),
                          curvature = cv, color = ink, linewidth = 0.45, linetype = "dashed",
                          arrow = grid::arrow(length = grid::unit(2.2, "mm"), angle = 22,
                                              type = "closed", ends = "both"), arrow.fill = ink)
    p <- p +
      geom_point(data = badge_data, aes(x = xm, y = ym), color = "white", size = 4.5) +
      geom_text(data = badge_data, aes(x = xm, y = ym, label = sign), color = ink, size = 4,
                fontface = "bold") +
      geom_text(data = function(d) d[d$element == "node", ],
                aes(x = x, y = y, label = from, color = from %in% highlight),
                size = tsize, show.legend = FALSE) +
      scale_color_manual(values = c(`TRUE` = "white", `FALSE` = ink), guide = "none") +
      geom_text(data = function(d) d[d$element == "node" & !is.na(d$label), ],
                aes(x = x, y = y - r - 0.06, label = label), vjust = 1, size = 3,
                color = "grey30", lineheight = 0.9) +
      coord_fixed(clip = "off") +
      scale_x_continuous(expand = expansion(add = 0.45)) +
      scale_y_continuous(expand = expansion(add = 0.55)) +
      theme_void()
  }
  p <- p + theme(
    plot.title = element_text(face = "bold", size = rel(1.1)),
    plot.subtitle = element_text(color = "grey30", size = rel(0.9)),
    plot.caption = element_text(color = "grey40", size = rel(0.75), hjust = 0),
    plot.title.position = "plot", plot.caption.position = "plot",
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(8, 8, 8, 8))
  if (isTRUE(caption)) p <- p + labs(caption = .qs_dag_caption(model, dd))
  p
}

# ---- prior against posterior -----------------------------------------------------------------

# x: the updated model, or output/tables/queries.csv (query_model() output with
# using = c("priors", "posteriors")). From the model, queries is a named list
# or character vector as for query_model(); the prior is drawn fresh at each
# call, so pass seed = model.seed. type = "density" overlays the two
# distributions (the plot data are the draws); "interval" shows mean, 50% and
# 95% equal-tailed intervals (the plot data are those summaries). From
# queries.csv the figure is always intervals, the table's own 95% intervals,
# so every number on it is in the table; queries selects labels.
# Population and subgroup queries only: a named case's probability has no
# distribution here.
qs_plot_prior_posterior <- function(x, queries = NULL, given = NULL,
                                    type = c("density", "interval"),
                                    seed = NULL, n_draws = 4000) {
  type <- match.arg(type)
  role_col <- c(prior = qs_colors[["prior"]], posterior = qs_colors[["posterior"]])
  if (is.data.frame(x)) {
    .qs_need(x, c("using", "mean", "cred.low", "cred.high"), "qs_plot_prior_posterior")
    s <- as.data.frame(x)
    case_level <- if ("case_level" %in% names(s)) s$case_level %in% TRUE else rep(FALSE, nrow(s))
    s <- s[s$using %in% c("priors", "posteriors", "prior", "posterior") & !case_level, ]
    lab <- if ("label" %in% names(s)) as.character(s$label) else as.character(s$query)
    if (!is.null(queries)) { keep <- lab %in% unlist(queries); s <- s[keep, ]; lab <- lab[keep] }
    g <- if ("given" %in% names(s)) as.character(s$given) else rep("-", nrow(s))
    s$query <- ifelse(g %in% c("-", "", NA), lab, paste0(lab, " | ", g))
    s$using <- factor(ifelse(grepl("^prior", s$using), "prior", "posterior"), levels = c("prior", "posterior"))
    s$query <- factor(s$query, levels = rev(unique(s$query)))
    s$ypos <- as.numeric(s$query) + ifelse(s$using == "prior", 0.15, -0.15)
    rownames(s) <- NULL
    return(ggplot(s, aes(y = ypos, color = using)) +
      geom_linerange(aes(xmin = cred.low, xmax = cred.high), linewidth = 0.6) +
      geom_point(aes(x = mean, shape = using), fill = "white", size = 2.4, stroke = 0.8) +
      scale_y_continuous(breaks = seq_along(levels(s$query)), labels = levels(s$query),
                         expand = expansion(add = 0.5)) +
      scale_color_manual(values = role_col) +
      scale_shape_manual(values = c(prior = 21, posterior = 16)) +
      labs(x = "Value of the query", y = NULL,
           caption = "Point: mean; bar: 95% credible interval (equal-tailed), as in the queries table.") +
      theme_qualstack(grid = "x"))
  }
  model <- x
  if (is.null(queries)) stop("qs_plot_prior_posterior(): name the queries to plot", call. = FALSE)
  queries <- as.list(queries)
  if (is.null(names(queries))) names(queries) <- unlist(queries)
  qn <- names(queries)
  g <- if (is.null(given)) NULL else rep_len(as.character(unlist(given)), length(queries))
  if (!is.null(seed)) set.seed(seed)
  draws <- function(using) {
    qd <- CausalQueries::query_distribution(model, queries = queries, given = g,
                                            using = using, n_draws = n_draws)
    data.frame(query = rep(qn, each = nrow(qd)), using = using,
               value = unlist(qd, use.names = FALSE))
  }
  d <- draws("priors")
  if ("posterior_distribution" %in% names(model)) {
    d <- rbind(d, draws("posteriors"))
  } else {
    message("qs_plot_prior_posterior(): the model has not been updated; plotting the prior only")
  }
  if (any(!is.finite(d$value))) {
    message("qs_plot_prior_posterior(): dropped ", sum(!is.finite(d$value)), " undefined draws")
    d <- d[is.finite(d$value), ]
  }
  d$query <- factor(d$query, levels = qn)
  d$using <- factor(ifelse(d$using == "priors", "prior", "posterior"), levels = c("prior", "posterior"))
  role_lty <- c(prior = "dashed", posterior = "solid")
  if (type == "density") {
    p <- ggplot(d, aes(x = value, color = using, fill = using, linetype = using))
    for (q in qn) {
      v <- d$value[d$query == q]
      lo <- if (min(v) < 0) -1 else 0
      p <- p + geom_density(data = local({ q <- q; function(x) x[x$query == q, ] }),
                            aes(alpha = using), bounds = c(lo, 1), linewidth = 0.6,
                            key_glyph = "path")
    }
    means <- stats::aggregate(value ~ query + using, data = d, FUN = mean)
    p <- p +
      geom_vline(data = means, aes(xintercept = value, color = using, linetype = using),
                 linewidth = 0.4, show.legend = FALSE) +
      scale_alpha_manual(values = c(prior = 0.12, posterior = 0.35), guide = "none") +
      scale_fill_manual(values = role_col) +
      scale_color_manual(values = role_col) +
      scale_linetype_manual(values = role_lty) +
      facet_wrap(~ query, scales = "free") +
      labs(x = "Value of the query", y = "Density",
           caption = "Dashed: prior; solid: posterior. Vertical lines: means.") +
      theme_qualstack(grid = "x")
  } else {
    s <- do.call(rbind, lapply(split(d, list(d$query, d$using), drop = TRUE), function(z) {
      qq <- stats::quantile(z$value, c(0.025, 0.25, 0.75, 0.975), names = FALSE)
      data.frame(query = z$query[1], using = z$using[1], mean = mean(z$value),
                 low95 = qq[1], low50 = qq[2], high50 = qq[3], high95 = qq[4], draws = nrow(z))
    }))
    s$query <- factor(s$query, levels = rev(qn))
    s$ypos <- as.numeric(s$query) + ifelse(s$using == "prior", 0.15, -0.15)
    rownames(s) <- NULL
    p <- ggplot(s, aes(y = ypos, color = using)) +
      geom_linerange(aes(xmin = low95, xmax = high95), linewidth = 0.5) +
      geom_linerange(aes(xmin = low50, xmax = high50), linewidth = 1.6) +
      geom_point(aes(x = mean, shape = using), fill = "white", size = 2.4, stroke = 0.8) +
      scale_y_continuous(breaks = seq_along(levels(s$query)), labels = levels(s$query),
                         expand = expansion(add = 0.5)) +
      scale_color_manual(values = role_col) +
      scale_shape_manual(values = c(prior = 21, posterior = 16)) +
      labs(x = "Value of the query", y = NULL,
           caption = "Point: mean; thick bar: 50% interval; thin bar: 95% interval (equal-tailed).") +
      theme_qualstack(grid = "x")
  }
  p
}

# ---- the evidence path of one case ---------------------------------------------------------------

# path: the evidence path /qualstack:process-trace saved in
# output/tables/trace-<case>.csv: qs_trace_case()'s path (step, clue, value,
# posterior; step 0 is the prior), rows of the counterfactual table in the
# same file are skipped; or qs_informal_trace() output (id, posterior,
# posterior_low, posterior_high), which has no prior row: pass prior =.
# Optional columns: evidence_id (shown under each clue), lower and upper (the
# posterior at the ends of the likelihood ranges), case (one panel per case).
# threshold draws the decision line the text uses, if any. The order of the
# steps is the order sought; it does not change the final answer.
qs_plot_evidence_path <- function(path, prior = NULL, threshold = NULL,
                                  ylab = "Probability the query is true") {
  d <- as.data.frame(path, stringsAsFactors = FALSE)
  if (!"step" %in% names(d) && all(c("id", "posterior") %in% names(d))) {   # qs_informal_trace()
    d$step <- seq_len(nrow(d)); d$clue <- as.character(d$id); d$value <- NA
  }
  if ("posterior_low" %in% names(d) && !"lower" %in% names(d)) d$lower <- d$posterior_low
  if ("posterior_high" %in% names(d) && !"upper" %in% names(d)) d$upper <- d$posterior_high
  .qs_need(d, c("step", "clue", "posterior"), "qs_plot_evidence_path")
  if (!"value" %in% names(d)) d$value <- NA
  if (!"case" %in% names(d)) d$case <- ""
  d <- d[!is.na(d$step) & !is.na(d$posterior), ]                 # path rows only
  if (!is.null(prior)) for (cs in unique(d$case)) if (!any(d$step[d$case == cs] == 0)) {
    row <- d[d$case == cs, ][1, ]
    row[] <- NA; row$case <- cs; row$step <- 0; row$clue <- "prior"; row$posterior <- prior
    d <- rbind(row, d)
  }
  d <- d[order(d$case, d$step), ]
  is_prior <- d$step == 0
  if (!any(is_prior)) warning("qs_plot_evidence_path(): no prior row (step 0); pass prior = so the path starts at the prior")
  clue <- vapply(as.character(d$clue), function(s) paste(strwrap(s, 16), collapse = "\n"), "")
  d$label <- ifelse(is_prior, "Prior",
                    ifelse(is.na(d$value) | d$value %in% "", clue,      # informal items: the item itself
                           ifelse(nchar(d$clue) > 6, paste0(clue, "\n= ", d$value),
                                  paste0(clue, " = ", d$value))))
  if ("evidence_id" %in% names(d))
    d$label <- ifelse(is.na(d$evidence_id) | !nzchar(d$evidence_id), d$label,
                      paste0(d$label, "\n", d$evidence_id))
  d$point <- ifelse(is_prior, "prior", "posterior")
  keys <- paste(d$case, sprintf("%04d", d$step))
  d$key <- factor(keys, levels = unique(keys))      # one x position per step, each panel its own
  priors <- d[is_prior, c("case", "posterior")]
  cap <- "Dashed line: the prior. Each step: the probability after that clue and every clue before it; the final value does not depend on the order."
  if (all(c("lower", "upper") %in% names(d))) cap <- c(cap, "Bars: the posterior at the ends of the likelihood ranges.")
  if (!is.null(threshold)) cap <- c(cap, paste0("Dotted line: ", threshold, ", the threshold the text uses."))
  p <- ggplot(d, aes(x = key, y = posterior, group = case)) +
    geom_blank() +
    geom_hline(data = priors, aes(yintercept = posterior), linetype = "dashed",
               color = qs_colors[["prior"]], linewidth = 0.4)
  if (!is.null(threshold))
    p <- p + geom_hline(yintercept = threshold, linetype = "dotted", color = qs_colors[["ink"]],
                        linewidth = 0.4)
  if (all(c("lower", "upper") %in% names(d)))
    p <- p + geom_linerange(aes(ymin = lower, ymax = upper), color = qs_colors[["posterior"]],
                            linewidth = 2.4, alpha = 0.3, na.rm = TRUE)
  p <- p +
    geom_step(direction = "hv", color = qs_colors[["posterior"]], linewidth = 0.7) +
    geom_point(aes(shape = point, color = point), fill = "white", size = 2.6, stroke = 0.9) +
    geom_text(aes(label = .qs_num(posterior)), hjust = -0.3, vjust = -0.5, size = 3, color = "grey20") +
    scale_shape_manual(values = c(prior = 21, posterior = 16), guide = "none") +
    scale_color_manual(values = c(prior = qs_colors[["prior"]], posterior = qs_colors[["posterior"]]),
                       guide = "none") +
    scale_x_discrete(labels = function(b) d$label[match(b, as.character(d$key))],
                     expand = expansion(add = c(0.4, 0.8))) +
    scale_y_continuous(limits = c(min(0, d$posterior, d$lower, na.rm = TRUE),
                                  max(1, d$posterior, d$upper, na.rm = TRUE) + 0.05),
                       breaks = function(lim) pretty(c(max(lim[1], -1), min(lim[2], 1))),
                       expand = expansion(add = 0.02)) +
    labs(x = "Clues, in the order sought", y = ylab, caption = .qs_wrap(cap)) +
    theme_qualstack(grid = "y")
  if (length(unique(d$case)) > 1) p <- p + facet_wrap(~ case, scales = "free_x")
  p
}

# ---- clue and case selection ---------------------------------------------------------------------

# tab: qs_clue_table() output (one bar per clue, labeled with its test type,
# the chance it is found, and the posterior if found / if absent) or
# qs_strategy_table() output (one bar per set of clues). highlight: the clue(s)
# or strategy chosen in the clue plan. A `given` column, if added, gives one
# panel per case type.
qs_plot_clue_learning <- function(tab, highlight = NULL) {
  d <- as.data.frame(tab)
  if ("exp_cost" %in% names(d)) stop("qs_plot_clue_learning(): two-step output; use qs_plot_frontier()", call. = FALSE)
  if ("clue" %in% names(d)) {
    .qs_need(d, c("clue", "exp_learning", "test", "p_found", "post_if_1", "post_if_0"), "qs_plot_clue_learning")
    d$item <- d$clue
    d$note <- paste0(ifelse(is.na(d$test), "", d$test), "; ", .qs_num(d$p_found), "; ",
                     ifelse(is.na(d$post_if_1), "-", .qs_num(d$post_if_1)), " / ",
                     ifelse(is.na(d$post_if_0), "-", .qs_num(d$post_if_0)))
    cap <- paste0("Label: test type; probability the clue is found; posterior if found / if absent. ",
                  "Prior on the query: ", paste(unique(.qs_num(d$prior)), collapse = ", "), ".")
  } else {
    .qs_need(d, c("strategy", "clues", "exp_learning"), "qs_plot_clue_learning")
    d$item <- d$strategy
    d$note <- d$clues
    cap <- "Label: the clues sought together."
  }
  d$chosen <- d$item %in% highlight
  d$item <- stats::reorder(factor(d$item), d$exp_learning, FUN = max)
  top <- max(c(d$exp_learning, 0.05), na.rm = TRUE)
  p <- ggplot(d, aes(x = exp_learning, y = item)) +
    geom_col(aes(fill = chosen), width = 0.6) +
    geom_text(aes(label = note), hjust = -0.04, size = 2.9, color = "grey20") +
    scale_fill_manual(values = c(`TRUE` = qs_colors[["accent"]], `FALSE` = qs_colors[["posterior"]]),
                      guide = "none") +
    scale_x_continuous(labels = .qs_pct, limits = c(0, top * 2),
                       breaks = function(lim) { b <- pretty(c(0, min(1, top))); b[b <= 1] },
                       expand = expansion(mult = c(0, 0.02))) +
    labs(x = "Expected learning (share of the prior variance removed)", y = NULL,
         caption = .qs_wrap(paste0(cap, if (length(highlight)) " Highlighted: the choice in the clue plan."))) +
    theme_qualstack(grid = "x")
  pc <- .qs_panel_col(d)
  if (!is.na(pc)) p <- p + facet_wrap(stats::as.formula(paste("~", pc)))
  p
}

# Readable names for qs_two_step() strategies: "M; P if M=1" means seek M,
# then seek P only if M is found.
.qs_strategy_names <- function(d) {
  vapply(seq_len(nrow(d)), function(i) {
    k <- d$first[i]; a <- d$if_0[i]; b <- d$if_1[i]
    if (is.na(k)) return("no clues")
    if (is.na(a) && is.na(b)) return(k)
    if (!is.na(a) && !is.na(b) && a == b) return(paste0(k, ", then ", a))
    if (is.na(a)) return(paste0(k, "; ", b, " if ", k, "=1"))
    if (is.na(b)) return(paste0(k, "; ", a, " if ", k, "=0"))
    paste0(k, "; ", a, " if ", k, "=0, ", b, " if ", k, "=1")
  }, character(1))
}

# tab: qs_two_step() output. Undominated strategies (no other is both cheaper
# and more informative) are filled and joined by the frontier: the lowest
# expected variance attainable at each budget. label: "frontier" or "all".
qs_plot_frontier <- function(tab, label = c("frontier", "all")) {
  label <- match.arg(label)
  .qs_need(tab, c("strategy", "first", "if_0", "if_1", "exp_var", "exp_cost", "frontier"), "qs_plot_frontier")
  d <- as.data.frame(tab)
  d$name <- .qs_strategy_names(d)
  d$status <- factor(ifelse(d$frontier, "undominated", "dominated"), levels = c("undominated", "dominated"))
  rownames(d) <- NULL
  pc <- .qs_panel_col(d)
  labels_of <- function(x) {                       # one label per point; ties share it
    x <- if (label == "frontier") x[x$frontier, ] else x
    key <- paste(if (is.na(pc)) "" else x[[pc]], round(x$exp_cost, 6), round(x$exp_var, 9))
    do.call(rbind, lapply(split(x, key), function(z) {
      out <- data.frame(exp_cost = z$exp_cost[1], exp_var = z$exp_var[1], frontier = z$frontier[1],
                        name = paste(z$name, collapse = " | "))
      if (!is.na(pc)) out[[pc]] <- z[[pc]][1]
      out
    }))
  }
  frontier_line <- function(x) {                   # panels with two or more undominated points
    f <- x[x$frontier, ]
    panel <- if (is.na(pc)) rep("", nrow(f)) else as.character(f[[pc]])
    f <- f[panel %in% names(which(table(panel) >= 2)), ]
    f[order(f$exp_cost, -f$exp_var), ]
  }
  p <- ggplot(d, aes(x = exp_cost, y = exp_var)) +
    geom_step(data = frontier_line, direction = "hv", color = qs_colors[["accent"]], linewidth = 0.5) +
    geom_point(aes(shape = status, color = status), size = 2.3, stroke = 0.8) +
    geom_text(data = labels_of, aes(label = name), hjust = 0, vjust = -0.6, nudge_x = 0.02,
              size = 2.8, color = "grey20") +
    scale_shape_manual(values = c(undominated = 16, dominated = 1), drop = FALSE) +
    scale_color_manual(values = c(undominated = qs_colors[["accent"]], dominated = qs_colors[["muted"]]),
                       drop = FALSE) +
    scale_x_continuous(expand = expansion(mult = c(0.04, 0.25))) +
    scale_y_continuous(expand = expansion(mult = c(0.05, 0.12))) +
    labs(x = "Expected cost", y = "Expected posterior variance",
         caption = .qs_wrap(paste0("\"M; P if M=1\": seek M, then seek P only if M is found. Line: the ",
                                   "lowest expected variance attainable at each budget."))) +
    theme_qualstack()
  if (!is.na(pc)) p <- p + facet_wrap(stats::as.formula(paste("~", pc)), scales = "free")
  p
}

# "X==1 & Y==1" -> "X1Y1"; anything else is kept as written.
.qs_cell_label <- function(s) {
  vapply(s, function(z) {
    parts <- trimws(strsplit(z, "&", fixed = TRUE)[[1]])
    if (all(grepl("^[A-Za-z][A-Za-z0-9]*\\s*==\\s*[01]$", parts)))
      paste(gsub("\\s*==\\s*", "", parts), collapse = "") else z
  }, character(1), USE.NAMES = FALSE)
}

# tab: qs_case_strategies() output. One row per strategy: expected posterior
# variance after seeking the clues in its cases, against the prior variance
# (the dashed line: no process tracing). highlight: "best" (lowest expected
# variance), a strategy name, or NULL. Hollow points: a reweighting with
# effective sample size under 200 (rerun update_model() with more iterations).
qs_plot_case_strategies <- function(tab, highlight = "best") {
  .qs_need(tab, c("strategy", "cases", "prior_var", "exp_post_var"), "qs_plot_case_strategies")
  d <- as.data.frame(tab)
  rownames(d) <- NULL
  d$cells <- vapply(strsplit(d$cases, " + ", fixed = TRUE),
                    function(z) paste(.qs_cell_label(z), collapse = " + "), character(1))
  d$row <- paste0(d$strategy, " (", d$cells, ")")
  d$row <- stats::reorder(factor(d$row), -d$exp_post_var, FUN = min)
  pick <- if (identical(highlight, "best")) d$strategy[which.min(d$exp_post_var)] else highlight
  d$role <- factor(ifelse(d$strategy %in% pick, "chosen", "other"), levels = c("chosen", "other"))
  d$low_ess <- if ("min_ess" %in% names(d)) !is.na(d$min_ess) & d$min_ess < 200 else FALSE
  pv <- unique(d$prior_var)
  p <- ggplot(d, aes(y = row)) +
    geom_vline(xintercept = pv, linetype = "dashed", color = qs_colors[["prior"]], linewidth = 0.4) +
    geom_segment(aes(x = prior_var, xend = exp_post_var, yend = row), color = qs_colors[["muted"]],
                 linewidth = 0.6) +
    geom_point(aes(x = exp_post_var, color = role, shape = low_ess), fill = "white", size = 2.6,
               stroke = 0.9) +
    scale_color_manual(values = c(chosen = qs_colors[["accent"]], other = qs_colors[["posterior"]]),
                       guide = "none") +
    scale_shape_manual(values = c(`FALSE` = 16, `TRUE` = 21), guide = "none") +
    scale_x_continuous(limits = c(0, max(c(pv, d$exp_post_var)) * 1.05),
                       expand = expansion(mult = c(0, 0.02))) +
    labs(x = "Expected posterior variance", y = NULL,
         caption = .qs_wrap(paste0("Dashed line: the prior variance (no process tracing). Clues sought: ",
                                   paste(unique(d$clues), collapse = "; "), ".",
                                   if (any(d$low_ess)) " Hollow: effective sample size under 200." else ""))) +
    theme_qualstack(grid = "x")
  if ("query" %in% names(d) && length(unique(d$query)) > 1) p <- p + facet_wrap(~ query, scales = "free_x")
  p
}

# ---- sensitivity -----------------------------------------------------------------------------------

# tab: qs_sensitivity() output (or any data frame with a variant column
# `model`/`variant`, an estimate `mean`/`estimate`, and optionally an interval
# `cred.low`/`cred.high` or `lower`/`upper`). One panel per query (`label`,
# plus `given` when it varies); the base model (default: the first variant)
# is highlighted and its answer drawn as a dashed line. ref: reference lines
# (e.g. 0 for effects, 0.5 for probabilities).
qs_plot_sensitivity <- function(tab, base = NULL, ref = NULL) {
  d <- as.data.frame(tab)
  vcol <- .qs_first_col(d, c("model", "variant", "spec"))
  ecol <- .qs_first_col(d, c("mean", "estimate", "posterior"))
  if (is.na(vcol) || is.na(ecol))
    stop("qs_plot_sensitivity(): needs a variant column (model or variant) and an estimate (mean or estimate)",
         call. = FALSE)
  lcol <- .qs_first_col(d, c("cred.low", "lower", "low"))
  hcol <- .qs_first_col(d, c("cred.high", "upper", "high"))
  if ("using" %in% names(d) && length(unique(d$using)) > 1) {
    message("qs_plot_sensitivity(): several `using` values; plotting the posteriors")
    d <- d[d$using %in% c("posteriors", "posterior"), ]
  }
  d$variant <- as.character(d[[vcol]])
  d$est <- d[[ecol]]
  d$lo <- if (is.na(lcol)) NA_real_ else d[[lcol]]
  d$hi <- if (is.na(hcol)) NA_real_ else d[[hcol]]
  if (is.null(base)) base <- d$variant[1]
  lev <- unique(c(base, d$variant))
  d$variant <- factor(d$variant, levels = rev(lev))
  d$role <- factor(ifelse(d$variant == base, "base model", "variant"), levels = c("base model", "variant"))
  facet <- if ("label" %in% names(d)) as.character(d$label) else "answer"
  if ("given" %in% names(d) && length(unique(d$given)) > 1)
    facet <- ifelse(d$given %in% c("-", "", NA), facet, paste0(facet, " | ", d$given))
  d$panel <- factor(facet, levels = unique(facet))
  d$flag <- ""
  if ("sign_flip" %in% names(d)) d$flag <- ifelse(d$sign_flip %in% TRUE, "sign flips", d$flag)
  if ("crosses_half" %in% names(d))
    d$flag <- ifelse(d$crosses_half %in% TRUE & d$role == "variant",
                     ifelse(nzchar(d$flag), paste0(d$flag, "; crosses 0.5"), "crosses 0.5"), d$flag)
  cap <- paste0("Diamond: the base model (", base, "), its answer dashed; circles: the model ",
                "variants, one change each.")
  has_bars <- any(d$hi - d$lo > 1e-9, na.rm = TRUE)   # case-level and parameter answers have none
  if (has_bars) cap <- paste(cap, "Bars: 95% credible intervals.")
  dcol <- .qs_first_col(d, c("base_determined", "determined"))
  if (!is.na(dcol)) {
    det <- unique(as.character(d$panel[d$role == "base model" & d[[dcol]] %in% TRUE]))
    if (length(det)) cap <- c(cap, paste0("Fixed by the base model's restrictions (an assumption, ",
                                          "not a finding): ", paste(det, collapse = "; "), "."))
  }
  p <- ggplot(d, aes(x = est, y = variant)) +
    geom_vline(data = d[d$role == "base model", ], aes(xintercept = est), linetype = "dashed",
               color = qs_colors[["accent"]], linewidth = 0.4)
  if (!is.null(ref)) p <- p + geom_vline(xintercept = ref, color = qs_colors[["muted"]], linewidth = 0.5)
  if (has_bars)
    p <- p + geom_linerange(aes(xmin = lo, xmax = hi, color = role), linewidth = 0.6, na.rm = TRUE)
  p <- p +
    geom_point(aes(color = role, shape = role), size = 2.6) +
    geom_text(data = d[nzchar(d$flag), ], aes(label = flag), hjust = -0.15, vjust = -0.6, size = 2.7,
              color = "grey20") +
    scale_color_manual(values = c(`base model` = qs_colors[["accent"]], variant = qs_colors[["posterior"]]),
                       guide = "none") +
    scale_shape_manual(values = c(`base model` = 18, variant = 16), guide = "none") +
    labs(x = "Answer to the query", y = NULL, caption = .qs_wrap(cap)) +
    theme_qualstack(grid = "x")
  if (length(levels(d$panel)) > 1) p <- p + facet_wrap(~ panel, scales = "free_x")
  p
}

# ---- chronology -------------------------------------------------------------------------------------

# Dates as the evidence log writes them: ISO 8601 at the known precision
# ("1989", "1989-05", "1989-05-12"), "?" appended when inferred, "A/B" for a
# span. Returns start, end, precision, inferred.
qs_parse_dates <- function(x) {
  one <- function(s) {
    s <- trimws(as.character(s))
    inferred <- grepl("\\?", s)
    s <- gsub("\\?", "", s)
    if (grepl("/", s, fixed = TRUE)) {
      ab <- strsplit(s, "/", fixed = TRUE)[[1]]
      a <- one(ab[1]); b <- one(ab[2])
      return(data.frame(start = a$start, end = b$end, precision = "span",
                        inferred = inferred | a$inferred | b$inferred))
    }
    if (grepl("^\\d{4}-\\d{2}-\\d{2}$", s)) {
      d0 <- as.Date(s); d1 <- d0; pr <- "day"
    } else if (grepl("^\\d{4}-\\d{2}$", s)) {
      d0 <- as.Date(paste0(s, "-01")); d1 <- seq(d0, by = "month", length.out = 2)[2] - 1; pr <- "month"
    } else if (grepl("^\\d{4}$", s)) {
      d0 <- as.Date(paste0(s, "-01-01")); d1 <- as.Date(paste0(s, "-12-31")); pr <- "year"
    } else {
      d0 <- as.Date(NA); d1 <- as.Date(NA); pr <- NA_character_
    }
    data.frame(start = d0, end = d1, precision = pr, inferred = inferred)
  }
  if (inherits(x, "Date")) return(data.frame(start = x, end = x, precision = "day", inferred = FALSE))
  do.call(rbind, lapply(x, one))
}

# The first Markdown table in a memo whose header has a column matching each
# regular expression in `columns` (header names lowercased, other characters
# turned into "_"), as a data frame of character columns. 06-figures.R reads
# the numbers a memo owns this way (the running posterior of an informal
# process trace, the dates of a chronology) instead of retyping them.
qs_read_md_table <- function(path, columns) {
  lines <- readLines(path, warn = FALSE)
  is_row <- grepl("^\\s*\\|.*\\|\\s*$", lines)
  cells <- function(l) trimws(strsplit(gsub("^\\s*\\||\\|\\s*$", "", l), "|", fixed = TRUE)[[1]])
  norm <- function(h) gsub("^_|_$", "", tolower(gsub("[^A-Za-z0-9]+", "_", h)))
  i <- 1
  while (i <= length(lines)) {
    if (!is_row[i]) { i <- i + 1; next }
    j <- i
    while (j + 1 <= length(lines) && is_row[j + 1]) j <- j + 1
    hdr <- norm(cells(lines[i]))
    if (j > i + 1 && all(vapply(columns, function(cl) any(grepl(cl, hdr)), logical(1)))) {
      m <- do.call(rbind, lapply(lines[(i + 2):j], function(l) { z <- cells(l); length(z) <- length(hdr); z }))
      d <- as.data.frame(m, stringsAsFactors = FALSE)
      names(d) <- make.unique(ifelse(nzchar(hdr), hdr, "col"))
      return(d)
    }
    i <- j + 1
  }
  stop("qs_read_md_table(): no table with columns matching ", paste(columns, collapse = ", "),
       " in ", path, call. = FALSE)
}

# The chronology table of a /qualstack:chronology memo, with columns renamed
# to date (the event date, not a document date), event, evidence_id, and case
# (from the file name chronology-<case>.md when the table has none).
qs_read_chronology <- function(path) {
  d <- qs_read_md_table(path, c("date", "event|what|description"))
  hdr <- names(d)
  dated <- grep("date", hdr)
  date_col <- c(which(hdr %in% c("date", "event_date")),
                dated[!grepl("doc|source|written|access", hdr[dated])])[1]
  event_col <- setdiff(c(which(hdr %in% c("event", "what", "description")), grep("event", hdr)),
                       date_col)[1]
  if (is.na(date_col) || is.na(event_col))
    stop("qs_read_chronology(): no event-date and event columns in ", path, call. = FALSE)
  names(d)[date_col] <- "date"
  names(d)[event_col] <- "event"
  ev <- grep("^(evidence|evidence_ids?|e_?ids?|sources?)$", names(d))
  if (length(ev) && !"evidence_id" %in% names(d)) names(d)[ev[1]] <- "evidence_id"
  if (!"case" %in% names(d))
    d$case <- sub("^chronology-", "", tools::file_path_sans_ext(basename(path)))
  d
}

# events: date (as in the evidence log), event, and optionally case,
# evidence_id, precision (day | month | year, to coarsen a date written more
# finely than it is known). One row per event, earliest at the top, one panel
# per case. A point marks a date known to the day; a bar spans a month, a
# year, or a stated span, with no point inside it (that would claim a day),
# so events whose bars overlap have no established order. Hollow point or
# dashed bar: an inferred date. markers: data frame of date, label for
# vertical reference lines (the outcome, a juncture).
qs_plot_timeline <- function(events, markers = NULL, wrap = 48) {
  .qs_need(events, c("date", "event"), "qs_plot_timeline")
  d <- as.data.frame(events, stringsAsFactors = FALSE)
  if (!"case" %in% names(d)) d$case <- ""
  pd <- qs_parse_dates(d$date)
  if (any(is.na(pd$start))) stop("qs_plot_timeline(): unreadable date(s): ",
                                 paste(d$date[is.na(pd$start)], collapse = ", "), call. = FALSE)
  d$start <- pd$start; d$end <- pd$end; d$precision <- pd$precision; d$inferred <- pd$inferred
  if ("precision" %in% names(events)) {
    want <- tolower(as.character(events$precision))
    to_month <- want %in% "month" & d$precision %in% "day"
    to_year <- want %in% "year" & d$precision %in% c("day", "month")
    d$start[to_month] <- as.Date(format(d$start[to_month], "%Y-%m-01"))
    d$end[to_month] <- do.call(c, lapply(d$start[to_month], function(s)
      seq(s, by = "month", length.out = 2)[2] - 1))
    d$start[to_year] <- as.Date(format(d$start[to_year], "%Y-01-01"))
    d$end[to_year] <- as.Date(format(d$start[to_year], "%Y-12-31"))
    d$precision[to_month] <- "month"; d$precision[to_year] <- "year"
  }
  d <- d[order(d$case, d$start, d$end), ]
  ev <- if ("evidence_id" %in% names(d)) ifelse(is.na(d$evidence_id) | !nzchar(d$evidence_id), "",
                                                 paste0(" [", d$evidence_id, "]")) else ""
  node <- if ("node" %in% names(d)) ifelse(is.na(d$node) | !nzchar(d$node), "", paste0(d$node, ": ")) else ""
  rec <- if ("record_or_recollection" %in% names(d))
    grepl("^recollect", tolower(as.character(d$record_or_recollection))) else rep(FALSE, nrow(d))
  d$label <- vapply(paste0(node, d$event, ifelse(rec, " (recollection)", ""), ev),
                    function(s) paste(strwrap(s, wrap), collapse = "\n"), "")
  d$row <- factor(seq_len(nrow(d)), levels = rev(seq_len(nrow(d))))
  d$dated <- factor(ifelse(d$inferred, "inferred", "attested"), levels = c("attested", "inferred"))
  d$span <- d$end > d$start
  rownames(d) <- NULL
  # geom_blank() first: the y scale learns every row, in date order, before
  # layers that hold only some rows can append theirs out of order
  p <- ggplot(d, aes(y = row)) + geom_blank()
  if (!is.null(markers)) {
    mk <- as.data.frame(markers, stringsAsFactors = FALSE)
    mp <- qs_parse_dates(mk$date)
    mk$x <- mp$start + (mp$end - mp$start) / 2
    p <- p + geom_vline(data = mk, aes(xintercept = x), linetype = "dashed",
                        color = qs_colors[["prior"]], linewidth = 0.4) +
      geom_text(data = mk, aes(x = x, y = Inf, label = label), inherit.aes = FALSE, angle = 90,
                hjust = 1.05, vjust = -0.4, size = 2.7, color = "grey30")
  }
  p <- p +
    geom_segment(data = function(x) x[x$span & !x$inferred, ], aes(x = start, xend = end, yend = row),
                 linewidth = 2.4, color = qs_colors[["posterior"]], alpha = 0.4, lineend = "butt") +
    geom_segment(data = function(x) x[x$span & x$inferred, ], aes(x = start, xend = end, yend = row),
                 linewidth = 0.8, color = qs_colors[["posterior"]], linetype = "22", lineend = "butt") +
    geom_point(data = function(x) x[!x$span, ], aes(x = start, shape = dated),
               color = qs_colors[["posterior"]], fill = "white", size = 2.3, stroke = 0.9) +
    scale_shape_manual(values = c(attested = 16, inferred = 21), drop = FALSE, guide = "none") +
    scale_x_date(labels = function(b) {
      span <- if (sum(!is.na(b)) > 1) as.numeric(diff(range(b, na.rm = TRUE))) else 0
      format(b, if (span > 3 * 366) "%Y" else "%b %Y")
    }) +
    scale_y_discrete(labels = function(b) d$label[match(b, as.character(d$row))]) +
    labs(x = NULL, y = NULL,
         caption = .qs_wrap(paste0("Point: an event dated to the day. Bar: dated only to the month, ",
                                   "the year, or a stated span; events whose bars overlap have no ",
                                   "established order. Hollow point or dashed bar: an inferred date.",
                                   if (any(rec)) " (recollection): attested only by sources written later.",
                                   if ("evidence_id" %in% names(d)) " Brackets: evidence IDs."))) +
    theme_qualstack(grid = "x") +
    theme(axis.text.y = element_text(size = rel(0.8), lineheight = 0.9),
          plot.margin = margin(5.5, 16, 5.5, 5.5))
  if (length(unique(d$case)) > 1) p <- p + facet_grid(case ~ ., scales = "free_y", space = "free_y")
  p
}
