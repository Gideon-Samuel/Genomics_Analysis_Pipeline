# Install packages
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install(c(
  "TCGAbiolinks",
  "ComplexHeatmap",
  "circlize"
))

# Load libraries
library(TCGAbiolinks)
library(ComplexHeatmap)
library(circlize)

# Create directories
dir.create("data", showWarnings = FALSE)

dir.create(
  "results/figures",
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  "results/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

# Query TCGA-LUAD CNV data
query <- GDCquery(
  project = "TCGA-LUAD",
  data.category = "Copy Number Variation",
  data.type = "Copy Number Segment"
)

# Download data
GDCdownload(
  query,
  directory = "data",
  method = "api",
  files.per.chunk = 20
)

# Prepare CNV data
cnv_data <- GDCprepare(query, directory = "data")

# Save raw CNV table
write.csv(
  cnv_data,
  "results/tables/TCGA_LUAD_CNV_segments.csv",
  row.names = FALSE
)

# Select numeric CNV values
numeric_cols <- sapply(cnv_data, is.numeric)

cnv_matrix <- as.matrix(
  cnv_data[, numeric_cols]
)

# Remove columns with NA-only values
cnv_matrix <- cnv_matrix[
  ,
  colSums(is.na(cnv_matrix)) < nrow(cnv_matrix)
]

# Replace remaining NA
cnv_matrix[is.na(cnv_matrix)] <- 0

# Reduce matrix size for visualization
cnv_matrix_small <- cnv_matrix[
  1:min(200, nrow(cnv_matrix)),
  1:min(50, ncol(cnv_matrix))
]

# CNV heatmap
png(
  "results/figures/TCGA_LUAD_CNV_heatmap.png",
  width = 1200,
  height = 900,
  res = 150
)

Heatmap(
  cnv_matrix_small,
  name = "CNV",
  column_title = "TCGA-LUAD Copy Number Variation",
  show_row_names = FALSE,
  show_column_names = TRUE
)

dev.off()

# Amplification/deletion frequency
segment_means <- cnv_data$Segment_Mean

png(
  "results/figures/TCGA_LUAD_CNV_distribution.png",
  width = 1000,
  height = 700,
  res = 150
)

hist(
  segment_means,
  breaks = 100,
  main = "TCGA-LUAD CNV Segment Distribution",
  xlab = "Segment Mean",
  col = "steelblue"
)

dev.off()

# Summary statistics
summary_table <- data.frame(
  Metric = c(
    "Total Segments",
    "Mean Segment Value",
    "Median Segment Value",
    "Maximum Segment Value",
    "Minimum Segment Value"
  ),
  Value = c(
    nrow(cnv_data),
    mean(segment_means, na.rm = TRUE),
    median(segment_means, na.rm = TRUE),
    max(segment_means, na.rm = TRUE),
    min(segment_means, na.rm = TRUE)
  )
)

write.csv(
  summary_table,
  "results/tables/TCGA_LUAD_CNV_summary.csv",
  row.names = FALSE
)