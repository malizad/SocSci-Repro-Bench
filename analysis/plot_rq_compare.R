library(tidyverse)

df <- read_csv("RQ_match_results_stratified.csv", show_col_types = FALSE)

# Recode agent labels
df <- df %>%
  mutate(agent = recode(agent, "CC" = "Claude Code", "CX" = "Codex"))

# Reshape to long format for the three metrics
df_long <- df %>%
  select(agent, grouping_type, group_value,
         semantic_match_rate, all_matched_rate, ge60_matched_rate) %>%
  pivot_longer(cols = c(semantic_match_rate, all_matched_rate, ge60_matched_rate),
               names_to = "metric", values_to = "value") %>%
  mutate(metric = factor(metric,
    levels = c("semantic_match_rate", "all_matched_rate", "ge60_matched_rate"),
    labels = c("Task-Level Match Rate",
               "Paper-Level Match Rate",
               "Paper-Level \u2265 60% Match Rate")))

# Common dimensions for all plots
plot_w <- 10
plot_h <- 5

make_plot <- function(data, x_var) {
  ggplot(data, aes(x = .data[[x_var]], y = value, fill = agent)) +
    geom_col(position = position_dodge(width = 0.7), width = 0.6) +
    geom_text(aes(label = paste0(round(value * 100, 1), "%")),
              position = position_dodge(width = 0.7),
              vjust = -0.4, size = 3.2) +
    facet_wrap(~ metric) +
    scale_y_continuous(limits = c(0, 1.08), breaks = seq(0, 1, 0.25),
                       labels = scales::percent_format(accuracy = 1)) +
    scale_fill_manual(values = c("Claude Code" = "darkorange2", "Codex" = "cyan3")) +
    labs(x = NULL, y = "Accuracy (%)", fill = NULL) +
    theme_minimal(base_size = 14) +
    theme(
      legend.position = "bottom",
      strip.text = element_text(face = "bold", size = 12),
      panel.grid.major.x = element_blank(),
      axis.text.x = element_text(size = 11)
    )
}

# 1) Overall
p1 <- df_long %>% filter(grouping_type == "overall") %>% make_plot("group_value")
ggsave("rq_compare_overall_cc_vs_cx.jpg", p1, width = plot_w, height = plot_h, dpi = 300)

# 2) Time
p2 <- df_long %>% filter(grouping_type == "time") %>%
  mutate(group_value = factor(group_value, levels = c("pre-cutoff", "post-cutoff"))) %>%
  make_plot("group_value")
ggsave("rq_compare_time_cc_vs_cx.jpg", p2, width = plot_w, height = plot_h, dpi = 300)

# 3) Language
p3 <- df_long %>% filter(grouping_type == "language", group_value %in% c("R", "Python", "Stata")) %>%
  mutate(group_value = factor(group_value, levels = c("R", "Python", "Stata"))) %>%
  make_plot("group_value")
ggsave("rq_compare_language_cc_vs_cx.jpg", p3, width = plot_w, height = plot_h, dpi = 300)

# 4) Repo — exclude Dryad, (none), Zenodo, CodeOcean
p4 <- df_long %>%
  filter(grouping_type == "Repo",
         !group_value %in% c("Dryad", "(none)", "Zenodo", "CodeOcean")) %>%
  make_plot("group_value")
ggsave("rq_compare_repo_cc_vs_cx.jpg", p4, width = plot_w, height = plot_h, dpi = 300)
