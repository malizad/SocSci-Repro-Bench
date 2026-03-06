library(jsonlite)
library(ggplot2)

cc <- fromJSON("accuracy_summary_cc.json")
cx <- fromJSON("accuracy_summary_cx.json")

# Compute means — no rounding of intermediates
cc_task_acc    <- mean(c(cc$r1$task_accuracy, cc$r2$task_accuracy, cc$r3$task_accuracy))
cc_task_nodata <- mean(c(cc$r1$task_nodata_accuracy, cc$r2$task_nodata_accuracy, cc$r3$task_nodata_accuracy))
cc_paper_acc   <- mean(c(cc$r1$paper_accuracy, cc$r2$paper_accuracy, cc$r3$paper_accuracy))

cx_task_acc    <- mean(c(cx$r1$task_accuracy_percent, cx$r2$task_accuracy_percent, cx$r3$task_accuracy_percent))
cx_task_nodata <- mean(c(cx$r1$task_nodata_accuracy, cx$r2$task_nodata_accuracy, cx$r3$task_nodata_accuracy))
cx_paper_acc   <- mean(c(cx$r1$paper_accuracy_percent, cx$r2$paper_accuracy_percent, cx$r3$paper_accuracy_percent))

df <- data.frame(
  Facet = factor(c("Task", "Task", "Task", "Task", "Paper", "Paper"),
                 levels = c("Task", "Paper")),
  Category = factor(c("All Tasks\n(N = 221)", "All Tasks\n(N = 221)",
                       "Non-Reproducible Tasks\n(N = 10)", "Non-Reproducible Tasks\n(N = 10)",
                       "All Papers\n(N = 54)", "All Papers\n(N = 54)"),
                    levels = c("All Tasks\n(N = 221)", "Non-Reproducible Tasks\n(N = 10)",
                               "All Papers\n(N = 54)")),
  Model = factor(c("Claude Code", "Codex", "Claude Code", "Codex",
                    "Claude Code", "Codex"),
                 levels = c("Claude Code", "Codex")),
  Value = c(cc_task_acc, cx_task_acc, cc_task_nodata, cx_task_nodata,
            cc_paper_acc, cx_paper_acc)
)

df$Label <- sprintf("%.1f", df$Value)

p <- ggplot(df, aes(x = Category, y = Value, fill = Model)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_text(aes(label = Label),
            position = position_dodge(width = 0.8),
            vjust = -0.4, size = 3) +
  facet_grid(. ~ Facet, scales = "free_x", space = "free_x") +
  scale_fill_manual(values = c("Claude Code" = "darkorange2", "Codex" = "cyan3")) +
  scale_y_continuous(breaks = seq(0, 100, 25),
                     limits = c(0, 108),
                     expand = c(0, 0)) +
  labs(x = NULL, y = "Accuracy (%)", fill = NULL) +
  theme_bw() +
  theme(
    plot.title    = element_blank(),
    axis.text.x   = element_text(size = 14),
    axis.title.y  = element_text(size = 17),
    axis.text.y   = element_text(size = 11),
    strip.text    = element_text(size = 11),
    legend.position = "bottom",
    legend.text   = element_text(size = 9),
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank()
  )

ggsave("accuracy_comparison.png", p, width = 8, height = 5, dpi = 300)
cat("DONE\n")
