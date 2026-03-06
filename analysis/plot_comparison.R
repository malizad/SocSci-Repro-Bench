library(jsonlite)
library(ggplot2)
library(patchwork)

# Read data
cc <- fromJSON("accuracy_summary_cc.json")
cx <- fromJSON("accuracy_summary_cx.json")

# ============================================================
# Plot 1: Accuracy Comparison
# ============================================================

# Compute means for Claude Code (fields without _percent suffix)
cc_task_acc   <- mean(c(cc$r1$task_accuracy, cc$r2$task_accuracy, cc$r3$task_accuracy))
cc_nodata_acc <- mean(c(cc$r1$task_nodata_accuracy, cc$r2$task_nodata_accuracy, cc$r3$task_nodata_accuracy))
cc_paper_acc  <- mean(c(cc$r1$paper_accuracy, cc$r2$paper_accuracy, cc$r3$paper_accuracy))

# Compute means for Codex (fields with _percent suffix)
cx_task_acc   <- mean(c(cx$r1$task_accuracy_percent, cx$r2$task_accuracy_percent, cx$r3$task_accuracy_percent))
cx_nodata_acc <- mean(c(cx$r1$task_nodata_accuracy_percent, cx$r2$task_nodata_accuracy_percent, cx$r3$task_nodata_accuracy_percent))
cx_paper_acc  <- mean(c(cx$r1$paper_accuracy_percent, cx$r2$paper_accuracy_percent, cx$r3$paper_accuracy_percent))

# Build data frame
df_acc <- data.frame(
  category = c("All Tasks\n(N = 221)", "All Tasks\n(N = 221)",
               "Non-Reproducible Tasks\n(N = 10)", "Non-Reproducible Tasks\n(N = 10)",
               "All Papers\n(N = 54)", "All Papers\n(N = 54)"),
  model = c("Claude Code", "Codex", "Claude Code", "Codex", "Claude Code", "Codex"),
  value = c(cc_task_acc, cx_task_acc, cc_nodata_acc, cx_nodata_acc, cc_paper_acc, cx_paper_acc),
  facet = c("Task", "Task", "Task", "Task", "Paper", "Paper")
)

df_acc$category <- factor(df_acc$category,
  levels = c("All Tasks\n(N = 221)", "Non-Reproducible Tasks\n(N = 10)", "All Papers\n(N = 54)"))
df_acc$model <- factor(df_acc$model, levels = c("Claude Code", "Codex"))
df_acc$facet <- factor(df_acc$facet, levels = c("Task", "Paper"))
df_acc$label <- sprintf("%.1f", df_acc$value)

p1 <- ggplot(df_acc, aes(x = category, y = value, fill = model)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_text(aes(label = label),
            position = position_dodge(width = 0.7), vjust = -0.5, size = 3) +
  facet_grid(~ facet, scales = "free_x", space = "free_x") +
  scale_fill_manual(values = c("Claude Code" = "darkorange2", "Codex" = "cyan3")) +
  scale_y_continuous(breaks = seq(0, 100, 25), expand = c(0, 0)) +
  coord_cartesian(ylim = c(0, 108)) +
  labs(x = NULL, y = "Accuracy (%)", fill = NULL) +
  theme_bw() +
  theme(
    plot.title    = element_blank(),
    axis.text.x   = element_text(size = 13.2),
    axis.title.y  = element_text(size = 16.5),
    axis.text.y   = element_text(size = 11),
    strip.text    = element_text(size = 13.75, face = "bold"),
    legend.position = "bottom",
    legend.text   = element_text(size = 9),
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank(),
    panel.spacing = unit(1, "lines")
  )

ggsave("accuracy_comparison.png", p1, width = 10, height = 6, dpi = 300)
cat("Saved accuracy_comparison.png\n")

# ============================================================
# Plot 2: Fail Comparison
# ============================================================

# Compute means for Claude Code
cc_task_fail  <- mean(c(cc$r1$task_fail, cc$r2$task_fail, cc$r3$task_fail))
cc_paper_fail <- mean(c(cc$r1$paper_fail, cc$r2$paper_fail, cc$r3$paper_fail))

# Compute means for Codex
cx_task_fail  <- mean(c(cx$r1$task_fail_percent, cx$r2$task_fail_percent, cx$r3$task_fail_percent))
cx_paper_fail <- mean(c(cx$r1$paper_fail_percent, cx$r2$paper_fail_percent, cx$r3$paper_fail_percent))

# Build data frame
df_fail <- data.frame(
  category = c("All Tasks\n(N = 221)", "All Tasks\n(N = 221)",
               "All Papers\n(N = 54)", "All Papers\n(N = 54)"),
  model = c("Claude Code", "Codex", "Claude Code", "Codex"),
  value = c(cc_task_fail, cx_task_fail, cc_paper_fail, cx_paper_fail),
  facet = c("Task", "Task", "Paper", "Paper")
)

df_fail$category <- factor(df_fail$category,
  levels = c("All Tasks\n(N = 221)", "All Papers\n(N = 54)"))
df_fail$model <- factor(df_fail$model, levels = c("Claude Code", "Codex"))
df_fail$facet <- factor(df_fail$facet, levels = c("Task", "Paper"))
df_fail$label <- sprintf("%.1f", df_fail$value)

p2 <- ggplot(df_fail, aes(x = category, y = value, fill = model)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_text(aes(label = label),
            position = position_dodge(width = 0.7), vjust = -0.5, size = 3) +
  facet_grid(~ facet, scales = "free_x", space = "free_x") +
  scale_fill_manual(values = c("Claude Code" = "darkorange2", "Codex" = "cyan3")) +
  scale_y_continuous(breaks = seq(0, 100, 25), expand = c(0, 0)) +
  coord_cartesian(ylim = c(0, 108)) +
  labs(x = NULL, y = "Failure (%)", fill = NULL) +
  theme_bw() +
  theme(
    plot.title    = element_blank(),
    axis.text.x   = element_text(size = 13.2),
    axis.title.y  = element_text(size = 16.5),
    axis.text.y   = element_text(size = 11),
    strip.text    = element_text(size = 13.75, face = "bold"),
    legend.position = "bottom",
    legend.text   = element_text(size = 9),
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank(),
    panel.spacing = unit(1, "lines")
  )

ggsave("fail_comparison.png", p2, width = 5, height = 6, dpi = 300)
cat("Saved fail_comparison.png\n")

# ============================================================
# Combined Plot
# ============================================================

combined <- p1 + p2 +
  plot_layout(widths = c(2, 1), guides = "collect") &
  theme(legend.position = "bottom")

ggsave("accuracy_fail_comparison.png", combined, width = 14, height = 6, dpi = 300)
cat("Saved accuracy_fail_comparison.png\n")
