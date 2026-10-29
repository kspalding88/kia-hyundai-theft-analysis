# ═══════════════════════════════════════════════════════════════════════════════
# Kia/Hyundai Theft Seasonality Story
# "When Do Thieves Strike? The Monthly Pattern of Kia/Hyundai Thefts"
#
# Story arc:
#   1. Which months see the most Kia/Hyundai thefts overall? (Donut Chart)
#   2. How does seasonality differ by city? (Stacked Bar with Categorical Data)
#   3. Monthly pattern: Kia/Hyundai vs Other thefts (Stacked Area Chart)
#   4. Milwaukee's monthly breakdown by year (Area Chart)
#   5. Agency-level: do high-theft agencies cluster in certain regions? (Treemap)
#   6. The seasonal share: what % are Kia/Hyundai each month? (Line Chart)
#
# Required chart types used (4 of 6):
#   ✓ Donut Chart (Viz 1)
#   ✓ Stacked Bar with Categorical Data (Viz 2)
#   ✓ Stacked Area Chart (Viz 3)
#   ✓ Area Chart (Viz 4)
# ═══════════════════════════════════════════════════════════════════════════════

# ─── Load Libraries ──────────────────────────────────────────────────────────
library(dplyr)
library(ggplot2)
library(tidyr)
library(readxl)

# ─── Load All Four Datasets ──────────────────────────────────────────────────
city_thefts <- read.csv("kiaHyundaiThefts.csv")
agency_map <- read.csv("carTheftsMap.csv", na.strings = "-")
milwaukee <- read.csv("KiaHyundaiMilwaukeeData.csv")
vice_data <- read_excel("Motherboard VICE News Kia Hyundai Theft Data.xlsx")

# Set month as an ordered factor for proper ordering in plots
month_levels <- c("Jan","Feb","Mar","Apr","May","Jun",
                  "Jul","Aug","Sep","Oct","Nov","Dec")

city_thefts$month <- factor(city_thefts$month, levels = month_levels)
milwaukee$month <- factor(milwaukee$month, levels = month_levels)


# ═══════════════════════════════════════════════════════════════════════════════
# VISUALIZATION 1: DONUT CHART
# "Which Quarter Sees the Most Kia/Hyundai Thefts?"
# Dataset: kiaHyundaiThefts.csv
# ═══════════════════════════════════════════════════════════════════════════════

# Group months into quarters and sum thefts across all cities and years
quarterly <- city_thefts %>%
  mutate(quarter = case_when(
    month %in% c("Jan","Feb","Mar") ~ "Q1 (Jan-Mar)",
    month %in% c("Apr","May","Jun") ~ "Q2 (Apr-Jun)",
    month %in% c("Jul","Aug","Sep") ~ "Q3 (Jul-Sep)",
    month %in% c("Oct","Nov","Dec") ~ "Q4 (Oct-Dec)"
  )) %>%
  group_by(quarter) %>%
  summarize(total = sum(countKiaHyundaiThefts, na.rm = TRUE), .groups = "drop") %>%
  mutate(
    pct = total / sum(total),
    pct_label = paste0(round(pct * 100, 1), "%")
  )

# Donut chart
ggplot(quarterly, aes(x = 2, y = total, fill = quarter)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar(theta = "y") +
  xlim(0.5, 2.5) +
  scale_fill_manual(values = c(
    "Q1 (Jan-Mar)" = "#264653",
    "Q2 (Apr-Jun)" = "#2A9D8F",
    "Q3 (Jul-Sep)" = "#E9C46A",
    "Q4 (Oct-Dec)" = "#E76F51"
  )) +
  geom_text(aes(label = pct_label), position = position_stack(vjust = 0.5), size = 4.5) +
  labs(
    title = "Kia/Hyundai Thefts by Quarter (All Cities, 2019-2022)",
    subtitle = "Q4 (Oct-Dec) accounts for the largest share as the epidemic peaked",
    fill = "Quarter"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40")
  )


# ═══════════════════════════════════════════════════════════════════════════════
# VISUALIZATION 2: STACKED BAR CHART WITH CATEGORICAL DATA
# "Monthly Theft Totals by City: Who Gets Hit When?"
# Dataset: kiaHyundaiThefts.csv
# ═══════════════════════════════════════════════════════════════════════════════

# Sum Kia/Hyundai thefts by month across top 5 cities
top5_cities <- city_thefts %>%
  group_by(city) %>%
  summarize(total = sum(countKiaHyundaiThefts), .groups = "drop") %>%
  arrange(desc(total)) %>%
  head(5) %>%
  pull(city)

monthly_by_city <- city_thefts %>%
  filter(city %in% top5_cities) %>%
  group_by(month, city) %>%
  summarize(thefts = sum(countKiaHyundaiThefts, na.rm = TRUE), .groups = "drop")

# Stacked bar chart
ggplot(monthly_by_city, aes(x = month, y = thefts, fill = city)) +
  geom_bar(stat = "identity") +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Monthly Kia/Hyundai Thefts: Top 5 Cities (2019-2022 Combined)",
    subtitle = "Later months show higher totals driven by the 2022 surge",
    x = "Month",
    y = "Total Thefts",
    fill = "City"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(color = "gray40"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )


# ═══════════════════════════════════════════════════════════════════════════════
# VISUALIZATION 3: STACKED AREA CHART
# "Kia/Hyundai vs Other Thefts: Monthly Pattern Over Time"
# Dataset: kiaHyundaiThefts.csv
# ═══════════════════════════════════════════════════════════════════════════════

# Create time-ordered data with both theft types summed across all cities
monthly_types <- city_thefts %>%
  mutate(date_order = as.numeric(month) + (year - 2019) * 12) %>%
  group_by(date_order) %>%
  summarize(
    `Kia/Hyundai` = sum(countKiaHyundaiThefts, na.rm = TRUE),
    `Other Vehicles` = sum(countOtherThefts, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(cols = c(`Kia/Hyundai`, `Other Vehicles`),
               names_to = "type", values_to = "thefts")

# Stacked area chart
ggplot(monthly_types, aes(x = date_order, y = thefts, fill = type)) +
  geom_area(alpha = 0.8) +
  scale_fill_manual(values = c("Kia/Hyundai" = "#E63946", "Other Vehicles" = "#457B9D")) +
  labs(
    title = "Monthly Theft Volume: Kia/Hyundai vs Other Vehicles",
    subtitle = "Kia/Hyundai thefts were negligible before mid-2022, then exploded",
    x = "Month (since Jan 2019)",
    y = "Total Monthly Thefts",
    fill = "Vehicle Type"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(color = "gray40")
  )


# ═══════════════════════════════════════════════════════════════════════════════
# VISUALIZATION 4: AREA CHART
# "Milwaukee's Monthly Theft Pattern by Year"
# Dataset: KiaHyundaiMilwaukeeData.csv
# ═══════════════════════════════════════════════════════════════════════════════

# Milwaukee monthly totals by year — shows how the seasonal shape changed
milwaukee_monthly <- milwaukee %>%
  group_by(month, year) %>%
  summarize(thefts = sum(countKiaHyundaiThefts, na.rm = TRUE), .groups = "drop") %>%
  mutate(month_num = as.numeric(month))

# Area chart — one layer per year to show progression
ggplot(milwaukee_monthly, aes(x = month_num, y = thefts, fill = factor(year))) +
  geom_area(alpha = 0.6, position = "identity") +
  scale_fill_manual(values = c(
    "2019" = "#A8DADC",
    "2020" = "#457B9D",
    "2021" = "#E9C46A",
    "2022" = "#E63946"
  )) +
  scale_x_continuous(breaks = 1:12, labels = month_levels) +
  labs(
    title = "Milwaukee: Monthly Kia/Hyundai Thefts by Year",
    subtitle = "2021 peaked in summer; 2019/2022 show different seasonal patterns",
    x = "Month",
    y = "Kia/Hyundai Thefts",
    fill = "Year"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(color = "gray40"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )


# ═══════════════════════════════════════════════════════════════════════════════
# VISUALIZATION 5: TREEMAP
# "The Biggest Agencies: 2022 Theft Volume at a Glance"
# Dataset: carTheftsMap.csv
# ═══════════════════════════════════════════════════════════════════════════════

library(treemapify)  # install.packages("treemapify") if needed

# Top 20 agencies by 2022 thefts, with a simple size/color encoding
agency_top20 <- agency_map %>%
  filter(!is.na(countCarThefts2022)) %>%
  arrange(desc(countCarThefts2022)) %>%
  head(20) %>%
  mutate(short_name = sub(" PD$| SO$| City PD$| Metro PD$", "", geo_name))

# Treemap — size = thefts, color = theft count (gradient)
ggplot(agency_top20, aes(
  area = countCarThefts2022,
  fill = countCarThefts2022,
  label = paste0(short_name, "\n", format(countCarThefts2022, big.mark = ","))
)) +
  geom_treemap() +
  geom_treemap_text(colour = "white", place = "centre", size = 9) +
  scale_fill_gradient(low = "#457B9D", high = "#E63946") +
  labs(
    title = "Top 20 Agencies by Total Car Thefts in 2022",
    subtitle = "Size and color intensity reflect theft volume",
    fill = "Thefts"
  ) +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 10, color = "gray40")
  )


# ═══════════════════════════════════════════════════════════════════════════════
# VISUALIZATION 6: LINE CHART
# "The Seasonal Share: What Percentage Are Kia/Hyundai Each Month?"
# Dataset: kiaHyundaiThefts.csv + KiaHyundaiMilwaukeeData.csv + VICE context
# ═══════════════════════════════════════════════════════════════════════════════

# Average Kia/Hyundai percentage by month across all cities
monthly_pct <- city_thefts %>%
  group_by(month) %>%
  summarize(avg_pct = mean(percentKiaHyundai, na.rm = TRUE) * 100, .groups = "drop")

# Add Milwaukee's average for comparison
milwaukee_pct <- milwaukee %>%
  group_by(month) %>%
  summarize(avg_pct = mean(percentKiaHyundai, na.rm = TRUE) * 100, .groups = "drop") %>%
  mutate(source = "Milwaukee")

monthly_pct$source <- "13-City Average"

combined_pct <- bind_rows(monthly_pct, milwaukee_pct)

# Line chart comparing seasonal percentage patterns
ggplot(combined_pct, aes(x = month, y = avg_pct, color = source, group = source)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_color_manual(values = c("13-City Average" = "#457B9D", "Milwaukee" = "#E63946")) +
  labs(
    title = "Average Kia/Hyundai Share of Thefts by Month",
    subtitle = "Milwaukee consistently higher; both show late-year increases",
    x = "Month",
    y = "Avg. Kia/Hyundai % of All Thefts",
    color = "Source",
    caption = "Data: City-level dataset + Milwaukee dataset; VICE/Motherboard reporting"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(color = "gray40"),
    plot.caption = element_text(size = 8, color = "gray60"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

# ═══════════════════════════════════════════════════════════════════════════════
# END OF SEASONALITY STORY
#
# Summary:
#   1. Donut Chart — quarterly breakdown shows Q4 dominates
#   2. Stacked Bar — monthly totals by city, showing which cities peak when
#   3. Stacked Area — Kia vs Other over time, showing the 2022 explosion
#   4. Area Chart — Milwaukee by year, showing different seasonal shapes
#   5. Treemap — top agencies by volume (context from agency dataset)
#   6. Line Chart — seasonal percentage comparison (city avg vs Milwaukee)
#
# All four datasets referenced. 4 required chart types satisfied.
# ═══════════════════════════════════════════════════════════════════════════════
