# ─── Load Required Libraries ─────────────────────────────────────────────────
# Load tidyverse packages for data manipulation, visualization, and reshaping,
# plus readxl for reading Excel files.
library(dplyr)
library(ggplot2)
library(tidyr)
library(readxl)

# ─── Load Datasets ───────────────────────────────────────────────────────────

# City-level Kia/Hyundai theft data (13 cities, 2019-2022)
city_thefts <- read.csv("kiaHyundaiThefts.csv")

# Agency-level car theft map data (uses "-" for missing values)
agency_map <- read.csv("carTheftsMap.csv", na.strings = "-")

# Milwaukee-specific monthly theft data (2019-2022)
milwaukee <- read.csv("KiaHyundaiMilwaukeeData.csv")

# VICE News dataset (Excel file, Dec 2019 - Aug 2023)
vice_data <- read_excel("Motherboard VICE News Kia Hyundai Theft Data.xlsx")

# ─── Structural Inspection ───────────────────────────────────────────────────

cat("\n=== City Thefts Dataset ===\n")
dim(city_thefts)
str(city_thefts)
head(city_thefts)

cat("\n=== Agency Map Dataset ===\n")
dim(agency_map)
str(agency_map)
head(agency_map)

cat("\n=== Milwaukee Dataset ===\n")
dim(milwaukee)
str(milwaukee)
head(milwaukee)

cat("\n=== VICE Dataset ===\n")
dim(vice_data)
str(vice_data)
head(vice_data)

# ─── Missing Data Assessment ─────────────────────────────────────────────────

cat("\n=== Missing Data: City Thefts ===\n")
colSums(is.na(city_thefts))
sum(is.na(city_thefts))

cat("\n=== Missing Data: Agency Map ===\n")
colSums(is.na(agency_map))
sum(is.na(agency_map))

cat("\n=== Missing Data: Milwaukee ===\n")
colSums(is.na(milwaukee))
sum(is.na(milwaukee))

cat("\n=== Missing Data: VICE ===\n")
colSums(is.na(vice_data))
sum(is.na(vice_data))

# ─── Summary Statistics ──────────────────────────────────────────────────────

cat("\n=== Summary: City Thefts ===\n")
summary(city_thefts)

# How many rows per city?
cat("\nCities in the data:\n")
table(city_thefts$city)

cat("\n=== Summary: Agency Map ===\n")
summary(agency_map)

cat("\n=== Summary: Milwaukee ===\n")
summary(milwaukee)

cat("\n=== Summary: VICE Data ===\n")
summary(vice_data)

# ─── Distribution Plots ──────────────────────────────────────────────────────

# Histogram: Kia/Hyundai theft counts (city data)
ggplot(city_thefts, aes(x = countKiaHyundaiThefts)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  labs(title = "Distribution of Kia/Hyundai Thefts (City Data)",
       x = "Theft Count", y = "Frequency") +
  theme_minimal()

# Histogram: Other thefts (city data)
ggplot(city_thefts, aes(x = countOtherThefts)) +
  geom_histogram(bins = 30, fill = "coral", color = "white") +
  labs(title = "Distribution of Other Thefts (City Data)",
       x = "Theft Count", y = "Frequency") +
  theme_minimal()

# Histogram: Car thefts 2022 (agency map)
ggplot(agency_map, aes(x = countCarThefts2022)) +
  geom_histogram(bins = 30, fill = "darkgreen", color = "white") +
  labs(title = "Distribution of Car Thefts 2022 (Agency Map)",
       x = "Theft Count", y = "Frequency") +
  theme_minimal()

# Histogram: Kia/Hyundai thefts (Milwaukee)
ggplot(milwaukee, aes(x = countKiaHyundaiThefts)) +
  geom_histogram(bins = 20, fill = "purple", color = "white") +
  labs(title = "Distribution of Kia/Hyundai Thefts (Milwaukee)",
       x = "Theft Count", y = "Frequency") +
  theme_minimal()

# Histogram: first numeric column in VICE data
numeric_cols <- names(vice_data)[sapply(vice_data, is.numeric)]
if (length(numeric_cols) > 0) {
  ggplot(vice_data, aes(x = .data[[numeric_cols[1]]])) +
    geom_histogram(bins = 30, fill = "orange", color = "white") +
    labs(title = paste("Distribution of", numeric_cols[1], "(VICE Data)"),
         x = numeric_cols[1], y = "Frequency") +
    theme_minimal()
}

# ─── Basic Exploratory Patterns ──────────────────────────────────────────────

# Create a simple date order for plotting
city_thefts$date_order <- match(city_thefts$month, month.abb) +
  (city_thefts$year - 2019) * 12

# Total Kia/Hyundai thefts by month across all cities
monthly_totals <- city_thefts %>%
  group_by(date_order) %>%
  summarize(total_thefts = sum(countKiaHyundaiThefts, na.rm = TRUE))

ggplot(monthly_totals, aes(x = date_order, y = total_thefts)) +
  geom_line(color = "steelblue", linewidth = 1) +
  labs(title = "Total Kia/Hyundai Thefts Over Time (All Cities)",
       x = "Month (since Jan 2019)", y = "Total Thefts") +
  theme_minimal()

# Total thefts by city
city_totals <- city_thefts %>%
  group_by(city) %>%
  summarize(total_thefts = sum(countKiaHyundaiThefts, na.rm = TRUE))

ggplot(city_totals, aes(x = reorder(city, total_thefts), y = total_thefts)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Total Kia/Hyundai Thefts by City",
       x = "City", y = "Total Thefts") +
  coord_flip() +
  theme_minimal()

# Milwaukee thefts over time
milwaukee$date_order <- match(milwaukee$month, month.abb) +
  (milwaukee$year - 2019) * 12

ggplot(milwaukee, aes(x = date_order, y = countKiaHyundaiThefts)) +
  geom_line(color = "purple", linewidth = 1) +
  labs(title = "Milwaukee Kia/Hyundai Thefts Over Time",
       x = "Month (since Jan 2019)", y = "Theft Count") +
  theme_minimal()

# VICE data: plot thefts over time if a date-like column exists
# This depends on the actual column names in the Excel file.
# We'll use row index as a simple proxy for time ordering.
if (nrow(vice_data) > 0) {
  vice_data$row_index <- seq_len(nrow(vice_data))
  numeric_cols_vice <- names(vice_data)[sapply(vice_data, is.numeric)]
  numeric_cols_vice <- setdiff(numeric_cols_vice, "row_index")
  if (length(numeric_cols_vice) > 0) {
    ggplot(vice_data, aes(x = row_index, y = .data[[numeric_cols_vice[1]]])) +
      geom_line(color = "orange", linewidth = 1) +
      labs(title = paste("VICE Data:", numeric_cols_vice[1], "Over Rows"),
           x = "Row", y = numeric_cols_vice[1]) +
      theme_minimal()
  }
}
