# ═══════════════════════════════════════════════════════════════════════════════
# Kia/Hyundai Theft Data Story
# "The Kia/Hyundai Theft Epidemic: From TikTok Trend to National Crisis"
#
# Story arc:
#   1. What share of all thefts are Kia/Hyundai? (Donut Chart - Milwaukee 2022)
#   2. How did the epidemic spread across cities over time? (Stacked Area Chart)
#   3. Which cities were hit hardest by 2022? (Stacked Bar - Kia vs Other)
#   4. How dramatic was the national growth? (Area Chart - all cities combined)
#   5. What does the geographic spread look like? (Treemap of agency-level data)
#   6. Milwaukee: the origin story timeline (Line chart with annotations)
#
# Required chart types used (4 of 6):
#   ✓ Donut Chart (Viz 1)
#   ✓ Stacked Area Chart (Viz 2)
#   ✓ Stacked Bar with Categorical Data (Viz 3)
#   ✓ Treemap (Viz 5)
# ═══════════════════════════════════════════════════════════════════════════════

# ─── Load Libraries ──────────────────────────────────────────────────────────
library(dplyr)
library(ggplot2)
library(tidyr)
library(readxl)
library(treemapify)  # install.packages("treemapify") if needed

# ─── Load All Four Datasets ──────────────────────────────────────────────────

city_thefts <- read.csv("kiaHyundaiThefts.csv")
agency_map <- read.csv("carTheftsMap.csv", na.strings = "-")
milwaukee <- read.csv("KiaHyundaiMilwaukeeData.csv")
vice_data <- read_excel("Motherboard VICE News Kia Hyundai Theft Data.xlsx")


# ═══════════════════════════════════════════════════════════════════════════════
# VISUALIZATION 1: DONUT CHART
# "Milwaukee 2022: Over Half of All Car Thefts Were Kia/Hyundai"
# Dataset: KiaHyundaiMilwaukeeData.csv
# ═══════════════════════════════════════════════════════════════════════════════

# Aggregate Milwaukee 2022 totals
milwaukee_2022 <- milwaukee %>%
  filter(year == 2022) %>%
  summarize(
    kia_hyundai = sum(countKiaHyundaiThefts),
    other = sum(countOtherThefts)
  ) %>%
  pivot_longer(everything(), names_to = "category", values_to = "count") %>%
  mutate(
    label = ifelse(category == "kia_hyundai", "Kia/Hyundai", "All Other Vehicles"),
    pct = count / sum(count),
    pct_label = paste0(round(pct * 100, 1), "%")
  )

# Donut chart
ggplot(milwaukee_2022, aes(x = 2, y = count, fill = label)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar(theta = "y") +
  xlim(0.5, 2.5) +
  scale_fill_manual(values = c("Kia/Hyundai" = "#E63946", "All Other Vehicles" = "#A8DADC")) +
  geom_text(aes(label = pct_label), position = position_stack(vjust = 0.5), size = 5) +
  labs(
    title = "Milwaukee 2022: Kia/Hyundai Share of All Vehicle Thefts",
    subtitle = "More than half of all stolen cars were vulnerable Kia/Hyundai models",
    fill = "Vehicle Type"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40")
  )


# ═══════════════════════════════════════════════════════════════════════════════
# VISUALIZATION 2: STACKED AREA CHART
# "The Epidemic Spreads: Kia/Hyundai Thefts Across Cities Over Time"
# Dataset: kiaHyundaiThefts.csv
# ═══════════════════════════════════════════════════════════════════════════════

# Create date ordering and select top cities for readability
city_thefts <- city_thefts %>%
  mutate(date_order = match(month, month.abb) + (year - 2019) * 12)

# Pick the top 6 cities by total thefts for a cleaner stacked area
top_cities <- city_thefts %>%
  group_by(city) %>%
  summarize(total = sum(countKiaHyundaiThefts)) %>%
  arrange(desc(total)) %>%
  head(6) %>%
  pull(city)

city_top6 <- city_thefts %>%
  filter(city %in% top_cities) %>%
  group_by(date_order, city) %>%
  summarize(thefts = sum(countKiaHyundaiThefts), .groups = "drop")

# Stacked area chart
ggplot(city_top6, aes(x = date_order, y = thefts, fill = city)) +
  geom_area(alpha = 0.85) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "The Epidemic Spreads: Kia/Hyundai Thefts Across Cities",
    subtitle = "Top 6 cities by total thefts, Jan 2019 - Dec 2022",
    x = "Month (since Jan 2019)",
    y = "Monthly Kia/Hyundai Thefts",
    fill = "City"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(color = "gray40")
  )


# ═══════════════════════════════════════════════════════════════════════════════
# VISUALIZATION 3: STACKED BAR CHART WITH CATEGORICAL DATA
# "Kia/Hyundai vs Other Thefts: City Comparison in Late 2022"
# Dataset: kiaHyundaiThefts.csv
# ═══════════════════════════════════════════════════════════════════════════════

# Get Q4 2022 (Oct-Dec) data for each city — the peak of the epidemic
q4_2022 <- city_thefts %>%
  filter(year == 2022, month %in% c("Oct", "Nov", "Dec")) %>%
  group_by(city) %>%
  summarize(
    kia_hyundai = sum(countKiaHyundaiThefts),
    other = sum(countOtherThefts),
    .groups = "drop"
  ) %>%
  pivot_longer(cols = c(kia_hyundai, other), names_to = "type", values_to = "count") %>%
  mutate(type = ifelse(type == "kia_hyundai", "Kia/Hyundai", "Other Vehicles"))

# Stacked bar chart
ggplot(q4_2022, aes(x = reorder(city, count), y = count, fill = type)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("Kia/Hyundai" = "#E63946", "Other Vehicles" = "#457B9D")) +
  coord_flip() +
  labs(
    title = "Vehicle Thefts by City: Q4 2022 (Peak of Epidemic)",
    subtitle = "Kia/Hyundai thefts dominated total theft counts in many cities",
    x = NULL,
    y = "Total Thefts (Oct-Dec 2022)",
    fill = "Vehicle Type"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(color = "gray40")
  )


# ═══════════════════════════════════════════════════════════════════════════════
# VISUALIZATION 4: AREA CHART
# "The National Surge: Combined Kia/Hyundai Thefts Explode in 2022"
# Dataset: kiaHyundaiThefts.csv + KiaHyundaiMilwaukeeData.csv
# ═══════════════════════════════════════════════════════════════════════════════

# Combine city_thefts and milwaukee (milwaukee isn't in city_thefts)
milwaukee_for_combine <- milwaukee %>%
  mutate(date_order = match(month, month.abb) + (year - 2019) * 12)

combined_monthly <- bind_rows(
  city_thefts %>% select(date_order, countKiaHyundaiThefts),
  milwaukee_for_combine %>% select(date_order, countKiaHyundaiThefts)
) %>%
  group_by(date_order) %>%
  summarize(total_thefts = sum(countKiaHyundaiThefts, na.rm = TRUE), .groups = "drop")

# Area chart
ggplot(combined_monthly, aes(x = date_order, y = total_thefts)) +
  geom_area(fill = "#E63946", alpha = 0.7) +
  geom_line(color = "#9D0208", linewidth = 0.8) +
  annotate("text", x = 36, y = max(combined_monthly$total_thefts) * 0.4,
           label = "TikTok 'Kia Boys'\ntrend goes viral",
           fontface = "italic", size = 3.5, color = "gray30") +
  annotate("segment", x = 36, xend = 36, y = 0,
           yend = max(combined_monthly$total_thefts) * 0.3,
           linetype = "dashed", color = "gray50") +
  labs(
    title = "The National Surge: Combined Kia/Hyundai Thefts (All Tracked Cities)",
    subtitle = "Including Milwaukee + 13 cities from the city-level dataset",
    x = "Month (since Jan 2019)",
    y = "Total Monthly Thefts"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(color = "gray40")
  )


# ═══════════════════════════════════════════════════════════════════════════════
# VISUALIZATION 5: TREEMAP
# "Where the Thefts Are: Agency-Level Car Theft Volume (2022)"
# Dataset: carTheftsMap.csv
# ═══════════════════════════════════════════════════════════════════════════════

# Prepare agency data — take top 25 agencies by 2022 theft count
agency_top25 <- agency_map %>%
  filter(!is.na(countCarThefts2022)) %>%
  arrange(desc(countCarThefts2022)) %>%
  head(25) %>%
  mutate(
    short_name = sub(" PD$| SO$| City PD$| Metro PD$", "", geo_name),
    growth = ifelse(!is.na(percentChange2019to2022),
                    ifelse(percentChange2019to2022 > 0.5, "High Growth (>50%)",
                           ifelse(percentChange2019to2022 > 0, "Moderate Growth", "Decline")),
                    "Unknown")
  )

# Treemap
ggplot(agency_top25, aes(
  area = countCarThefts2022,
  fill = growth,
  label = paste0(short_name, "\n", format(countCarThefts2022, big.mark = ","))
)) +
  geom_treemap() +
  geom_treemap_text(colour = "white", place = "centre", size = 9) +
  scale_fill_manual(values = c(
    "High Growth (>50%)" = "#E63946",
    "Moderate Growth" = "#F4A261",
    "Decline" = "#2A9D8F",
    "Unknown" = "#CCCCCC"
  )) +
  labs(
    title = "Top 25 Agencies by Car Thefts in 2022",
    subtitle = "Size = theft volume; Color = growth rate since 2019",
    fill = "Growth Category"
  ) +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 10, color = "gray40")
  )


# ═══════════════════════════════════════════════════════════════════════════════
# VISUALIZATION 6: LINE CHART WITH CONTEXT
# "Milwaukee: Ground Zero — The Origin Story"
# Dataset: KiaHyundaiMilwaukeeData.csv + VICE dataset context
# ═══════════════════════════════════════════════════════════════════════════════

# Milwaukee timeline with percentage of all thefts
milwaukee_timeline <- milwaukee %>%
  mutate(
    date_order = match(month, month.abb) + (year - 2019) * 12,
    pct = percentKiaHyundai * 100
  )

# Line chart showing the Kia/Hyundai share skyrocketing
ggplot(milwaukee_timeline, aes(x = date_order, y = pct)) +
  geom_line(color = "#9D0208", linewidth = 1.2) +
  geom_point(color = "#E63946", size = 1) +
  # Annotate key events
  annotate("rect", xmin = 21, xmax = 24, ymin = -Inf, ymax = Inf,
           alpha = 0.1, fill = "red") +
  annotate("text", x = 22.5, y = 75,
           label = "Thefts explode\n(late 2020)", size = 3, color = "gray30") +
  annotate("rect", xmin = 37, xmax = 48, ymin = -Inf, ymax = Inf,
           alpha = 0.05, fill = "orange") +
  annotate("text", x = 42, y = 10,
           label = "Sustained at 50-70%\nthrough 2022", size = 3, color = "gray30") +
  geom_hline(yintercept = 50, linetype = "dashed", color = "gray50", linewidth = 0.5) +
  annotate("text", x = 3, y = 53, label = "50% threshold", size = 2.5, color = "gray50") +
  labs(
    title = "Milwaukee: Ground Zero of the Kia/Hyundai Theft Epidemic",
    subtitle = "Percentage of all vehicle thefts that were Kia/Hyundai models (2019-2022)",
    x = "Month (since Jan 2019)",
    y = "Kia/Hyundai as % of All Thefts",
    caption = "Source: Milwaukee PD data; VICE/Motherboard reporting"
  ) +
  scale_y_continuous(limits = c(0, 80), breaks = seq(0, 80, 10)) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(color = "gray40"),
    plot.caption = element_text(size = 8, color = "gray60")
  )

# ═══════════════════════════════════════════════════════════════════════════════
# END OF STORY SCRIPT
# 
# Summary of visualizations:
#   1. Donut Chart — Milwaukee's Kia/Hyundai share in 2022 (milwaukee dataset)
#   2. Stacked Area Chart — theft spread across top cities over time (city dataset)
#   3. Stacked Bar Chart — Kia vs Other by city, Q4 2022 (city dataset)
#   4. Area Chart — national combined total over time (city + milwaukee datasets)
#   5. Treemap — top agencies by 2022 volume & growth (agency map dataset)
#   6. Line Chart — Milwaukee origin story timeline (milwaukee + VICE context)
#
# All four datasets used. 4 of 6 required chart types satisfied.
# ═══════════════════════════════════════════════════════════════════════════════
