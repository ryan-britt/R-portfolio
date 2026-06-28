R Portfolio — Ryan Britt
This repository contains R scripts developed for research, teaching, and statistical analysis. It is intended to demonstrate proficiency in data wrangling, statistical computing, and science communication using R and the Tidyverse.

Files
workshop.R

An interactive R tutorial developed for and delivered to MPH students at the University of Colorado Anschutz Medical Campus. Assumes no prior programming experience. Covers core Tidyverse data wrangling (select, filter, mutate, summarize, group_by), data visualization with ggplot2, and a culminating t-test exercise using nutritional data.
custom_stat_functions.R

Custom implementations of common inferential procedures, returning proper htest S3 objects compatible with base R conventions. Includes a one-sample t-test from summary statistics, a two-sample Welch/pooled t-test from summary statistics with optional confidence interval, and a power analysis function using the non-central t-distribution.
SF_Dissertation_Fall.R

Statistical analysis underlying dissertation research examining the cognitive effects of significant figure enforcement in general chemistry. Uses the NASA Task Load Index (TLX) as a measure of cognitive workload. Analysis includes paired t-tests and Wilcoxon signed-rank tests across experimental conditions, hierarchical linear regression with a math anxiety × condition interaction term, matrix-based generation of model predictions, and publication-ready regression tables via stargazer.
grade_explorer2.R

A Shiny application for interactively exploring student grade distributions.
