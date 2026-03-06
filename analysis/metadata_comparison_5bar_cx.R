library(jsonlite)
library(ggplot2)

cx <- fromJSON("Papers_Metadata_CX_R1.json")
gold <- fromJSON("Papers_Metadata_Gold.json")

# Rename CX columns to align with gold
names(cx)[names(cx) == "paper_title"]   <- "title"
names(cx)[names(cx) == "paper_authors"] <- "authors"

# Merge on id
merged <- merge(cx, gold, by = "id", suffixes = c("_cx", "_gold"))

# Helper: check if value is NA string (case-insensitive, trimmed)
is_na_val <- function(x) tolower(trimws(as.character(x))) == "na"

# Helper: exact match after trimming
exact_match <- function(a, b) trimws(as.character(a)) == trimws(as.character(b))

# Compute stats for a field
compute_stats <- function(cx_col, gold_col) {
  n <- length(cx_col)
  unk <- sum(is_na_val(cx_col))
  non_unk <- !is_na_val(cx_col)
  matches <- sum(exact_match(cx_col[non_unk], gold_col[non_unk]))
  mismatches <- sum(non_unk) - matches
  c(Unknown = unk / n * 100,
    `Exact Match` = matches / n * 100,
    Mismatch = mismatches / n * 100)
}

title_stats   <- compute_stats(merged$title_cx, merged$title_gold)
authors_stats <- compute_stats(merged$authors_cx, merged$authors_gold)
journal_stats <- compute_stats(merged$journal_cx, merged$journal_gold)
year_stats    <- compute_stats(merged$year_cx, merged$year_gold)

# Compute overall stats at the paper level:
#   Unknown    = all four fields are NA
#   Exact Match = all four fields match exactly (none NA)
#   Mismatch   = everything else
n <- nrow(merged)
all_unk <- is_na_val(merged$title_cx) & is_na_val(merged$authors_cx) &
           is_na_val(merged$journal_cx) & is_na_val(merged$year_cx)
all_match <- exact_match(merged$title_cx, merged$title_gold) &
             exact_match(merged$authors_cx, merged$authors_gold) &
             exact_match(merged$journal_cx, merged$journal_gold) &
             exact_match(merged$year_cx, merged$year_gold)
overall_stats <- c(Unknown = sum(all_unk) / n * 100,
                   `Exact Match` = sum(all_match) / n * 100,
                   Mismatch = sum(!all_unk & !all_match) / n * 100)

df <- data.frame(
  Field = rep(c("Title", "Authors", "Journal", "Year", "Overall"), each = 3),
  Category = rep(c("Unknown", "Exact Match", "Mismatch"), times = 5),
  Percentage = c(title_stats, authors_stats, journal_stats, year_stats, overall_stats)
)

df$Field <- factor(df$Field, levels = c("Title", "Authors", "Journal", "Year", "Overall"))
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
  labs(title = "Metadata Comparison: Codex vs Gold Standard",
       x = NULL, y = "Percentage of Papers (n = 54)", fill = NULL) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
    legend.position = "top",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(face = "bold", size = 12)
  )

ggsave("metadata_comparison_5bar_cx.jpg", p, width = 8, height = 5, dpi = 300)
cat("Plot saved to metadata_comparison_5bar_cx.jpg\n")
