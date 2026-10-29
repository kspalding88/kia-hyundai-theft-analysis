# ═══════════════════════════════════════════════════════════════════════════════
# Kia/Hyundai Theft EDA — Base R Only (No Special Libraries)
#
# Uses only functions that come with a fresh R install.
# Note: The VICE Excel file requires readxl, so we skip it here or
#       you can export it to CSV first. We'll load the 3 CSVs directly.
# ═══════════════════════════════════════════════════════════════════════════════

# ─── Load the Three CSV Datasets ─────────────────────────────────────────────

city_thefts <- read.csv("kiaHyundaiThefts.csv", stringsAsFactors = FALSE)
agency_map <- read.csv("carTheftsMap.csv", na.strings = "-", stringsAsFactors = FALSE)
milwaukee <- read.csv("KiaHyundaiMilwaukeeData.csv", stringsAsFactors = FALSE)

# For the VICE Excel file, uncomment this if you have readxl available:
# library(readxl)
# vice_data <- read_excel("Motherboard VICE News Kia Hyundai Theft Data.xlsx")
#
# Otherwise, open the .xlsx in Excel and save as CSV, then:
# vice_data <- read.csv("Motherboard VICE News Kia Hyundai Theft Data.csv", stringsAsFactors = FALSE)


# ═══════════════════════════════════════════════════════════════════════════════
# DATASET 1: city_thefts (kiaHyundaiThefts.csv)
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n")
cat("════════════════════════════════════════════════════════════════════\n")
cat("  DATASET 1: City-Level Kia/Hyundai Thefts (13 cities, 2019-2022)\n")
cat("════════════════════════════════════════════════════════════════════\n")

# --- Dimensions ---
cat("\nDimensions:", nrow(city_thefts), "rows x", ncol(city_thefts), "columns\n")

# --- Structure ---
cat("\nColumn types:\n")
str(city_thefts)

# --- First few rows ---
cat("\nFirst 6 rows:\n")
head(city_thefts)

# --- Missing values ---
cat("\nMissing values per column:\n")
print(colSums(is.na(city_thefts)))
cat("Total NAs:", sum(is.na(city_thefts)), "\n")

# --- Summary statistics ---
cat("\nSummary statistics:\n")
summary(city_thefts)

# --- Unique cities ---
cat("\nCities in the data:\n")
print(table(city_thefts$city))

# --- Unique years ---
cat("\nYears in the data:\n")
print(table(city_thefts$year))

# --- Basic plots ---
# Histogram of Kia/Hyundai theft counts
hist(city_thefts$countKiaHyundaiThefts,
     breaks = 30,
     col = "steelblue",
     main = "Distribution of Monthly Kia/Hyundai Thefts (City Data)",
     xlab = "Theft Count",
     ylab = "Frequency")

# Histogram of other thefts
hist(city_thefts$countOtherThefts,
     breaks = 30,
     col = "coral",
     main = "Distribution of Monthly Other Vehicle Thefts (City Data)",
     xlab = "Theft Count",
     ylab = "Frequency")

# Boxplot by city
boxplot(countKiaHyundaiThefts ~ city, data = city_thefts,
        las = 2,
        col = "lightblue",
        main = "Kia/Hyundai Thefts by City",
        ylab = "Monthly Theft Count",
        cex.axis = 0.7)


# ═══════════════════════════════════════════════════════════════════════════════
# DATASET 2: agency_map (carTheftsMap.csv)
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n")
cat("════════════════════════════════════════════════════════════════════\n")
cat("  DATASET 2: Agency-Level Car Theft Map Data\n")
cat("════════════════════════════════════════════════════════════════════\n")

# --- Dimensions ---
cat("\nDimensions:", nrow(agency_map), "rows x", ncol(agency_map), "columns\n")

# --- Structure ---
cat("\nColumn types:\n")
str(agency_map)

# --- First few rows ---
cat("\nFirst 6 rows:\n")
head(agency_map)

# --- Missing values ---
cat("\nMissing values per column:\n")
print(colSums(is.na(agency_map)))
cat("Total NAs:", sum(is.na(agency_map)), "\n")

# --- Summary statistics ---
cat("\nSummary statistics:\n")
summary(agency_map)

# --- Verify no literal "-" remains (should all be NA now) ---
char_cols <- names(agency_map)[sapply(agency_map, is.character)]
has_dash <- sapply(agency_map[char_cols], function(x) any(x == "-", na.rm = TRUE))
cat("\nColumns still containing literal '-':", 
    ifelse(any(has_dash), paste(names(has_dash)[has_dash], collapse = ", "), "NONE"), "\n")

# --- Basic plots ---
# Histogram of 2022 thefts
hist(agency_map$countCarThefts2022,
     breaks = 40,
     col = "darkgreen",
     main = "Distribution of Agency-Level Car Thefts (2022)",
     xlab = "Theft Count",
     ylab = "Frequency")

# Histogram of percent change 2019 to 2022
hist(agency_map$percentChange2019to2022,
     breaks = 40,
     col = "orange",
     main = "Distribution of Theft % Change (2019 to 2022)",
     xlab = "Percent Change",
     ylab = "Frequency")

# Scatter: 2019 thefts vs 2022 thefts
plot(agency_map$countCarThefts2019, agency_map$countCarThefts2022,
     pch = 16, col = rgb(0, 0.5, 0, 0.5),
     main = "Car Thefts: 2019 vs 2022 by Agency",
     xlab = "Thefts in 2019",
     ylab = "Thefts in 2022")
abline(a = 0, b = 1, col = "red", lty = 2)  # diagonal = no change


# ═══════════════════════════════════════════════════════════════════════════════
# DATASET 3: milwaukee (KiaHyundaiMilwaukeeData.csv)
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n")
cat("════════════════════════════════════════════════════════════════════\n")
cat("  DATASET 3: Milwaukee Kia/Hyundai Theft Data (2019-2022)\n")
cat("════════════════════════════════════════════════════════════════════\n")

# --- Dimensions ---
cat("\nDimensions:", nrow(milwaukee), "rows x", ncol(milwaukee), "columns\n")

# --- Structure ---
cat("\nColumn types:\n")
str(milwaukee)

# --- First few rows ---
cat("\nFirst 6 rows:\n")
head(milwaukee)

# --- Missing values ---
cat("\nMissing values per column:\n")
print(colSums(is.na(milwaukee)))
cat("Total NAs:", sum(is.na(milwaukee)), "\n")

# --- Summary statistics ---
cat("\nSummary statistics:\n")
summary(milwaukee)

# --- Year breakdown ---
cat("\nThefts by year:\n")
print(tapply(milwaukee$countKiaHyundaiThefts, milwaukee$year, sum))

# --- Basic plots ---
# Histogram
hist(milwaukee$countKiaHyundaiThefts,
     breaks = 20,
     col = "purple",
     main = "Distribution of Monthly Kia/Hyundai Thefts (Milwaukee)",
     xlab = "Theft Count",
     ylab = "Frequency")

# Time series line plot
milwaukee$date_order <- match(milwaukee$month,
  c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")) +
  (milwaukee$year - 2019) * 12

plot(milwaukee$date_order, milwaukee$countKiaHyundaiThefts,
     type = "l", col = "purple", lwd = 2,
     main = "Milwaukee Kia/Hyundai Thefts Over Time",
     xlab = "Month (since Jan 2019)",
     ylab = "Theft Count")
grid()

# Percentage over time
plot(milwaukee$date_order, milwaukee$percentKiaHyundai * 100,
     type = "l", col = "red", lwd = 2,
     main = "Milwaukee: Kia/Hyundai as % of All Thefts",
     xlab = "Month (since Jan 2019)",
     ylab = "Percent",
     ylim = c(0, 80))
abline(h = 50, lty = 2, col = "gray50")
grid()


# ═══════════════════════════════════════════════════════════════════════════════
# DATASET 4: VICE Data (Excel — requires export to CSV or readxl)
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n")
cat("════════════════════════════════════════════════════════════════════\n")
cat("  DATASET 4: VICE/Motherboard Data\n")
cat("════════════════════════════════════════════════════════════════════\n")

# If you exported the Excel to CSV:
# vice_data <- read.csv("Motherboard VICE News Kia Hyundai Theft Data.csv",
#                       stringsAsFactors = FALSE)

# If you have readxl installed, uncomment:
# library(readxl)
# vice_data <- read_excel("Motherboard VICE News Kia Hyundai Theft Data.xlsx")

# Once loaded, run the same EDA pattern:
# cat("\nDimensions:", nrow(vice_data), "rows x", ncol(vice_data), "columns\n")
# str(vice_data)
# head(vice_data)
# cat("\nMissing values per column:\n")
# print(colSums(is.na(vice_data)))
# cat("Total NAs:", sum(is.na(vice_data)), "\n")
# summary(vice_data)

cat("\n** NOTE: The VICE dataset is an Excel file (.xlsx). **\n")
cat("   Option A: Use library(readxl) and read_excel() to load it.\n")
cat("   Option B: Open in Excel, Save As CSV, then use read.csv().\n")
cat("   Uncomment the code above once you pick an option.\n")


# ═══════════════════════════════════════════════════════════════════════════════
# QUICK CROSS-DATASET COMPARISON
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n")
cat("════════════════════════════════════════════════════════════════════\n")
cat("  CROSS-DATASET COMPARISON\n")
cat("════════════════════════════════════════════════════════════════════\n")

# Total Kia/Hyundai thefts per year (city data)
cat("\nTotal Kia/Hyundai thefts by year (13-city dataset):\n")
print(tapply(city_thefts$countKiaHyundaiThefts, city_thefts$year, sum))

# Milwaukee vs all others
cat("\nMilwaukee total by year:\n")
print(tapply(milwaukee$countKiaHyundaiThefts, milwaukee$year, sum))

# Top 10 agencies by 2022 thefts
cat("\nTop 10 agencies by 2022 car thefts:\n")
top10 <- agency_map[order(-agency_map$countCarThefts2022), ]
print(top10[1:10, c("geo_name", "countCarThefts2022", "percentChange2019to2022")])

# Agencies with biggest percent increase
cat("\nTop 10 agencies by % increase (2019 to 2022):\n")
top_growth <- agency_map[order(-agency_map$percentChange2019to2022), ]
print(top_growth[1:10, c("geo_name", "countCarThefts2019", "countCarThefts2022", "percentChange2019to2022")])
