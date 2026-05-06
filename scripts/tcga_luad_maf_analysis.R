# Install required packages
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install(c("TCGAbiolinks", "maftools"))

# Load libraries
library(TCGAbiolinks)
library(maftools)

# Create directories
dir.create("data", showWarnings = FALSE)

dir.create(
  "results/genomics/figures",
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  "results/genomics/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

# Query TCGA-LUAD mutation data
query <- GDCquery(
  project = "TCGA-LUAD",
  data.category = "Simple Nucleotide Variation",
  data.type = "Masked Somatic Mutation",
  workflow.type = "Aliquot Ensemble Somatic Variant Merging and Masking"
)

# Download mutation data
GDCdownload(query, directory = "data")

# Prepare MAF object
maf_data <- GDCprepare(query, directory = "data")

maf <- read.maf(maf = maf_data)

# Mutation summary plot
png(
  "results/genomics/figures/maf_summary.png",
  width = 1200,
  height = 800,
  res = 150
)

plotmafSummary(maf)

dev.off()

# Oncoplot
png(
  "results/genomics/figures/oncoplot.png",
  width = 1200,
  height = 900,
  res = 150
)

oncoplot(
  maf = maf,
  top = 20
)

dev.off()

# TP53 lollipop plot
png(
  "results/genomics/figures/tp53_lollipop.png",
  width = 1000,
  height = 700,
  res = 150
)

lollipopPlot(
  maf = maf,
  gene = "TP53"
)

dev.off()

# Gene mutation summary table
gene_summary <- getGeneSummary(maf)

write.csv(
  gene_summary,
  "results/genomics/tables/gene_summary.csv",
  row.names = FALSE
)