# Kia/Hyundai Vehicle Theft Analysis

A data visualization and storytelling project in R examining the surge in
Kia and Hyundai vehicle thefts across U.S. cities beginning in late 2020,
when a missing engine immobilizer in budget-trim models became a widely
publicized vulnerability.

## Overview

This project turns several public theft datasets into a six-visualization data
story aimed at a non-technical audience — municipal safety planners and city
council members. The goal is to show, clearly and quickly, that Kia/Hyundai
thefts spiked after 2020, that the problem spans major metros nationwide, and
that an affordable mitigation (steering-column lock kits and resident
notification) exists.

It is a visualization and communication project rather than a modeling project:
the emphasis is on data wrangling, time-series/seasonality patterns, and
presenting findings a stakeholder can act on.

## Data

All data is from publicly available records (aggregated at the city or agency
level — no personally identifiable information):

| File | Description | Source |
|------|-------------|--------|
| `KiaHyundaiMilwaukeeData.csv` | Milwaukee monthly theft counts, 2019–2023 | Milwaukee Police Department public crime statistics |
| `kiaHyundaiThefts.csv` | Multi-city theft statistics | Compiled from city police department reports |
| `carTheftsMap.csv` | Geographic agency-level theft data | FBI Uniform Crime Reporting (UCR) |

A fourth dataset referenced in the write-up (VICE/Motherboard FOIA data) informs
the treemap of theft volume by city.

## The Six Visualizations

| # | Visual | What it shows |
|---|--------|---------------|
| 1 | Donut chart | National share of Kia/Hyundai thefts vs. other vehicles (~11.8% vs. 88.2%) |
| 2 | Area chart | Milwaukee monthly Kia/Hyundai thefts, 2019–2023 — the explosive spike |
| 3 | Stacked area chart | Milwaukee Kia/Hyundai thefts layered against other vehicle thefts over time |
| 4 | Pie chart | National 11.8% share vs. Milwaukee's ~66.5% peak share |
| 5 | Stacked bar chart | Top 10 cities by total thefts, split by Kia/Hyundai vs. other |
| 6 | Treemap | Theft volume by city, sized by magnitude |

A consistent two-color palette (steelblue for Kia/Hyundai, coral for other) is
used across all six so color always carries the same meaning. Design choices
follow Gestalt principles and WCAG AA contrast.

## Methods & Data Preparation

- **Missing-value handling:** `"-"` placeholders in the geographic data converted
  to `NA`; agencies with missing values excluded for the affected year only, with
  the excluded count documented in chart footnotes.
- **Date construction:** month names + year combined into R `Date` objects for
  correct chronological ordering.
- **Aggregation:** monthly city-level counts rolled up to yearly totals.
- **Proportions:** Kia/Hyundai share computed with a division-by-zero guard.
- **Top-N filtering:** the stacked bar chart shows the top 10 cities, labeled as
  such in the title so no filtering is hidden.

## Repository Contents

```
*.csv                               Public theft datasets (read from the project root)
kia_theft_final.Rmd                 Main R Markdown analysis and visuals
kia_theft_visualization.Rmd         Visualization-focused R Markdown
kia_hyundai_theft_eda.R             Exploratory data analysis
kia_theft_eda_base_r.R              EDA in base R
kia_theft_story.R                   Data-story visualization script
kia_theft_seasonality_story.R       Seasonality / time-series analysis
docs/                               Story design and ethical-considerations write-up
```

The R scripts read the CSV files from the project root. Charts are written to a
`figures/` folder when the scripts run.

## How to Run

Requires R (with `ggplot2` and base graphics). From the project root:

```r
# Render the main analysis
rmarkdown::render("kia_theft_final.Rmd")

# Or run an individual script
source("kia_theft_story.R")
```

## Tools

R, ggplot2, base R graphics, R Markdown.
