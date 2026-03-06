library(jsonlite)
library(ggplot2)

cc <- fromJSON("Papers_Metadata_CC_R3.json")
gold <- fromJSON("Papers_Metadata_Gold.json")

# Merge on id
merged <- merge(cc, gold, by = "id", suffixes = c("_cc", "_gold"))

# Helper: check if value is Unknown (case-insensitive, trimmed)
is_unknown <- function(x) tolower(trimws(as.character(x))) == "unknown"

# Helper: exact match after trimming
exact_match <- function(a, b) trimws(as.character(a)) == trimws(as.character(b))

# Compute stats for a field
compute_stats <- function(cc_col, gold_col) {
  n <- length(cc_col)
  unk <- sum(is_unknown(cc_col))
  non_unk <- !is_unknown(cc_col)
  matches <- sum(exact_match(cc_col[non_unk], gold_col[non_unk]))
  mismatches <- sum(non_unk) - matches
  c(Unknown = unk / n * 100,
    `Exact Match` = matches / n * 100,
    Mismatch = mismatches / n * 100)
}

title_stats   <- compute_stats(merged$title_cc, merged$title_gold)
authors_stats <- compute_stats(merged$authors_cc, merged$authors_gold)
journal_stats <- compute_stats(merged$journal_cc, merged$journal_gold)
year_stats    <- compute_stats(merged$year_cc, merged$year_gold)

df <- data.frame(
  Field = rep(c("Title", "Authors", "Journal", "Year"), each = 3),
  Category = rep(c("Unknown", "Exact Match", "Mismatch"), times = 4),
  Percentage = c(title_stats, authors_stats, journal_stats, year_stats)
)

df$Field <- factor(df$Field, levels = c("Title", "Authors", "Journal", "Year"))
df$Category <- factor(df$Category, levels = c("Mismatch", "Exact Match", "Unknown"))

colors <- c("Unknown"    = "#999999",
            "Exact Match" = "#2ca02c",
            "Mismatch"    = "#d62728")

p <- ggplot(df, aes(x = Field, y = Percentage, fill = Category)) +
  geom_bar(stat = "identity", width = 0.65) +
  geom_text(aes(label = ifelse(Percentage >= 4,
                                paste0(sprintf("%.1f", Percentage), "%"), "")),
            position = position_stack(vjust = 0.5), size = 3.8, color = "white",
            fontface = "bold") +
  scale_fill_manual(values = colors) +
  scale_y_continuous(labels = function(x) paste0(x, "%"), expand = c(0, 0)) +
  labs(title = "Metadata Comparison: Claude Code vs Gold Standard",
       x = NULL, y = "Percentage of Papers (n = 54)", fill = NULL) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
    legend.position = "top",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(face = "bold", size = 12)
  )

ggsave("metadata_comparison.jpg", p, width = 7, height = 5, dpi = 300)
cat("Plot saved to metadata_comparison.jpg\n")
