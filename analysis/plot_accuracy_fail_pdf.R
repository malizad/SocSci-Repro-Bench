library(jsonlite)
library(ggplot2)
library(patchwork)

# Read data
cc_base <- fromJSON("accuracy_summary_cc.json")
cc_pdf  <- fromJSON("accuracy_summary_cc_pdf.json")
cx_base <- fromJSON("accuracy_summary_cx.json")
cx_pdf  <- fromJSON("accuracy_summary_cx_pdf.json")

# ============================================================
# Helper: build accuracy + fail combined plot for one agent
# ============================================================
make_combined <- function(base, pdf, base_field_suffix, pdf_field_suffix,
                          col_base, col_pdf, out_file) {

  get_mean <- function(dat, field) {
    mean(c(dat$r1[[field]], dat$r2[[field]], dat$r3[[field]]))
  }

  bf <- base_field_suffix
  pf <- pdf_field_suffix

  # --- Accuracy data ---
  df_acc <- data.frame(
    category = rep(c("All Tasks\n(N = 221)", "Non-Reproducible\nTasks (N = 10)",
                      "All Papers\n(N = 54)"), each = 2),
    condition = rep(c("Anonymized", "Anonymized + PDF"), 3),
    value = c(
      get_mean(base, paste0("task_accuracy", bf)),
      get_mean(pdf,  paste0("task_accuracy", pf)),
      get_mean(base, paste0("task_nodata_accuracy", bf)),
      get_mean(pdf,  paste0("task_nodata_accuracy", pf)),
      get_mean(base, paste0("paper_accuracy", bf)),
      get_mean(pdf,  paste0("paper_accuracy", pf))
    ),
    facet = rep(c("Task", "Task", "Paper"), each = 2)
  )
  df_acc$category  <- factor(df_acc$category,
    levels = c("All Tasks\n(N = 221)", "Non-Reproducible\nTasks (N = 10)",
               "All Papers\n(N = 54)"))
  df_acc$condition <- factor(df_acc$condition, levels = c("Anonymized", "Anonymized + PDF"))
  df_acc$facet     <- factor(df_acc$facet, levels = c("Task", "Paper"))
  df_acc$label     <- sprintf("%.1f", df_acc$value)

  p1 <- ggplot(df_acc, aes(x = category, y = value, fill = condition)) +
    geom_col(position = position_dodge(width = 0.7), width = 0.6,
             colour = "black", linewidth = 0.3) +
    geom_text(aes(label = label),
              position = position_dodge(width = 0.7), vjust = -0.5, size = 3) +
    facet_grid(~ facet, scales = "free_x", space = "free_x") +
    scale_fill_manual(values = c("Anonymized" = col_base, "Anonymized + PDF" = col_pdf)) +
    scale_y_continuous(breaks = seq(0, 100, 25), expand = c(0, 0)) +
    coord_cartesian(ylim = c(0, 108)) +
    labs(x = NULL, y = "Accuracy (%)", fill = NULL) +
    theme_bw() +
    theme(
      plot.title         = element_blank(),
      axis.text.x        = element_text(size = 17),
      axis.title.y       = element_text(size = 24),
      axis.text.y        = element_text(size = 11),
      strip.text         = element_text(size = 22, face = "bold"),
      legend.position    = "bottom",
      legend.text        = element_text(size = 14),
      panel.grid.major.x = element_blank(),
      panel.grid.minor   = element_blank(),
      panel.spacing      = unit(1, "lines")
    )

  # --- Fail data ---
  df_fail <- data.frame(
    category = rep(c("All Tasks\n(N = 221)", "All Papers\n(N = 54)"), each = 2),
    condition = rep(c("Anonymized", "Anonymized + PDF"), 2),
    value = c(
      get_mean(base, paste0("task_fail", bf)),
      get_mean(pdf,  paste0("task_fail", pf)),
      get_mean(base, paste0("paper_fail", bf)),
      get_mean(pdf,  paste0("paper_fail", pf))
    ),
    facet = rep(c("Task", "Paper"), each = 2)
  )
  df_fail$category  <- factor(df_fail$category,
    levels = c("All Tasks\n(N = 221)", "All Papers\n(N = 54)"))
  df_fail$condition <- factor(df_fail$condition, levels = c("Anonymized", "Anonymized + PDF"))
  df_fail$facet     <- factor(df_fail$facet, levels = c("Task", "Paper"))
  df_fail$label     <- sprintf("%.1f", df_fail$value)

  p2 <- ggplot(df_fail, aes(x = category, y = value, fill = condition)) +
    geom_col(position = position_dodge(width = 0.7), width = 0.6,
             colour = "black", linewidth = 0.3) +
    geom_text(aes(label = label),
              position = position_dodge(width = 0.7), vjust = -0.5, size = 3) +
    facet_grid(~ facet, scales = "free_x", space = "free_x") +
    scale_fill_manual(values = c("Anonymized" = col_base, "Anonymized + PDF" = col_pdf)) +
    scale_y_continuous(breaks = seq(0, 100, 25), expand = c(0, 0)) +
    coord_cartesian(ylim = c(0, 108)) +
    labs(x = NULL, y = "Fail (%)", fill = NULL) +
    theme_bw() +
    theme(
      plot.title         = element_blank(),
      axis.text.x        = element_text(size = 17),
      axis.title.y       = element_text(size = 24),
      axis.text.y        = element_text(size = 11),
      strip.text         = element_text(size = 22, face = "bold"),
      legend.position    = "bottom",
      legend.text        = element_text(size = 14),
      panel.grid.major.x = element_blank(),
      panel.grid.minor   = element_blank(),
      panel.spacing      = unit(1, "lines")
    )

  combined <- p1 + p2 +
    plot_layout(widths = c(2, 1), guides = "collect") &
    theme(legend.position = "bottom")

  ggsave(out_file, combined, width = 14, height = 6, dpi = 300)
  cat("Saved", out_file, "\n")
}

# ============================================================
# Claude Code: baseline has no _percent suffix, pdf has _percent
# ============================================================
make_combined(cc_base, cc_pdf, "", "_percent",
              "darkorange", "lightsalmon",
              "accuracy_fail_comparison_cc_pdf.png")

# ============================================================
# Codex: both baseline and pdf use _percent suffix
# ============================================================
make_combined(cx_base, cx_pdf, "_percent", "_percent",
              "cyan3", "paleturquoise",
              "accuracy_fail_comparison_cx_pdf.png")

cat("Done.\n")
