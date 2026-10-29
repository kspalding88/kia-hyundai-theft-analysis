# Kia/Hyundai Theft Crisis: Story Design & Ethical Considerations

**Kyle Spalding**
**DSC 640 — Data Presentation & Visualization**

---

## Summary

The Kia and Hyundai theft crisis that swept across the United States beginning in late 2020 represents a compelling case study in how a single design vulnerability—the lack of an engine immobilizer in budget-trim vehicles—can produce cascading public safety consequences. This presentation tells that story through six data visualizations delivered via PowerPoint, targeting municipal safety planners and city council members who are positioned to act on the findings.

**Audience.** The intended audience consists of municipal safety planners, city council members, and civic advocacy stakeholders. These individuals are educated professionals who understand policy proposals and budget discussions, but they are not data scientists. They are unfamiliar with the raw theft datasets and do not work with statistical terminology daily. Because of this, the presentation avoids technical jargon such as "distributions" or "standard deviations" and instead uses plain language like "theft count," "percentage share," and "spike." The visuals are designed to be immediately interpretable without requiring a statistics background, while still conveying the severity and geographic scope of the problem.

**Purpose.** This presentation is not merely informational—it drives toward a specific call to action. The intent is to recommend that cities with the highest Kia/Hyundai theft volumes mandate the installation of steering column lock kits (already available from the manufacturers) and launch targeted resident notification campaigns. The audience should walk away understanding three things: (1) Kia/Hyundai thefts exploded after 2020 due to a known design flaw, (2) this is not isolated to one city but affects major metros nationwide, and (3) a concrete, affordable solution exists. The presentation recommends policy change and promotes a new direction in municipal theft prevention.

**Medium.** A PowerPoint slide deck was selected because city council meetings and safety board briefings are conducted via slide presentations. This format allows the presenter to narrate the data story sequentially, control pacing, and answer questions slide-by-slide. PowerPoint also supports embedded high-resolution chart images exported from R, making it a natural bridge between the analytical environment and the presentation environment.

**Design.** All design decisions were guided by Gestalt's principles of visual perception. A two-color palette—Steelblue (#4682B4) for Kia/Hyundai and Coral (#FF7F50) for other vehicles—provides warm-versus-cool contrast that passes WCAG AA accessibility standards. This palette remains consistent across all six visuals so that color always carries the same meaning (Similarity). Text follows a hierarchical sizing strategy: 14-point bold titles, 11-point body text, and 9-point axis labels, all in sans-serif fonts for screen readability. Alignment is left-justified for titles and labels (following natural Western reading direction) and center-aligned for donut/pie percentage callouts. Chart sizing is standardized at 1024×768 pixels at 300 DPI to ensure clarity in both projected and printed formats. Spacing uses generous margins with inter-chart gaps larger than intra-chart padding, leveraging Gestalt Proximity so each visual reads as its own perceptual unit. Additional principles applied include Continuity (smooth area curves guide the eye along timelines), Closure (white borders on pie/treemap segments let the brain parse boundaries), Figure/Ground (white backgrounds with subtle shadows separate chart layers), Common Fate (the October 2020 annotation marks where trends shift direction together), and Symmetry and Order (evenly spaced bars, balanced margins, and sequential slide numbering).

---

## Visuals

Six visualizations are included in the presentation, five of which come from the required list:

| # | Visual Type | Required List? | Description |
|---|-------------|---------------|-------------|
| 1 | Donut Chart | Yes | National proportion of Kia/Hyundai thefts vs. other vehicles (11.8% vs 88.2%) |
| 2 | Area Chart | Yes | Milwaukee Kia/Hyundai monthly theft counts from 2019–2023 showing the explosive spike |
| 3 | Stacked Area Chart | Yes | Milwaukee Kia/Hyundai thefts layered against other vehicle thefts over time |
| 4 | Pie Chart | Yes | Before-and-after comparison: national 11.8% share vs. Milwaukee's 66.5% peak share |
| 5 | Stacked Bar Chart | Yes | Top 10 cities by total thefts with Kia/Hyundai vs. Other segments |
| 6 | Tree Map | Yes | Theft volume by city from the VICE/Motherboard FOIA dataset, sized by magnitude |

All six visuals use the consistent steelblue/coral palette and follow the same typographic and spacing conventions described above.

---

## Ethical Considerations

### What changes were made to the data?

Several transformations were applied to prepare the raw datasets for visualization:

- **Dash-to-NA conversion.** The geographic dataset (carTheftsMap.csv) uses "-" as a placeholder for missing values. These were converted to NA using a safe coercion function. Agencies with missing values were excluded from aggregation for the affected year only, and the count of excluded agencies is documented in chart footnotes.
- **Date construction.** Month names and year integers were combined into R Date objects for chronological ordering. No underlying data values were altered—only a sortable representation was created.
- **Aggregation.** Monthly city-level theft counts were summed to produce yearly totals for the stacked bar chart. This is a standard roll-up that preserves total magnitude.
- **Proportion calculation.** Kia/Hyundai share was computed as kia_count divided by total count. A division-by-zero guard was applied for months with zero total thefts to prevent errors.
- **Top-N filtering.** The stacked bar chart shows only the top 10 cities by total thefts. This filter is clearly labeled in the chart title ("Top 10 Cities") so the audience knows remaining cities were excluded from that specific visual.

### Are there any legal or regulatory guidelines for your data?

All datasets are sourced from publicly available records:

- Milwaukee Police Department monthly crime statistics (government public records)
- VICE/Motherboard data obtained through Freedom of Information Act (FOIA) requests
- Multi-city theft statistics compiled from individual city police department reports
- FBI Uniform Crime Reporting (UCR) geographic agency data

No personally identifiable information (PII) is present in any dataset—all records are aggregated at the city or agency level. No HIPAA, FERPA, or GDPR regulations apply. Redistribution for academic purposes falls under fair use of government and public data.

### What risks could be created based on transformations or how visualizations are presented?

| Risk | Description | Severity |
|------|-------------|----------|
| Copycat encouragement | Highlighting the ease of Kia/Hyundai theft could inadvertently normalize or encourage the behavior | Medium |
| Brand stigmatization | Naming specific manufacturers may unfairly damage brand reputation beyond what the data supports | Medium |
| Ecological fallacy | City-level aggregates may mask neighborhood-level variation; viewers might assume uniform risk across an entire city | Low |
| Correlation ≠ causation | The October 2020 timeline annotation may imply social media caused the spike, but the data alone cannot prove causation | Medium |
| Incomplete geographic coverage | The UCR dataset includes only agencies that voluntarily report; non-reporting areas are invisible and may understate the national problem | Low |

### Did you make any assumptions in cleaning/transforming or presenting the data?

- **Reporting consistency.** We assume each city's police department counts and reports thefts using compatible definitions across the 2019–2023 timeframe.
- **Dashes mean missing, not zero.** Dashes in the geographic data are treated as missing rather than zero thefts. This is documented but could undercount if some agencies truly experienced zero thefts.
- **Vehicle make accuracy.** We assume the source data correctly identified vehicle makes. Misclassification would skew the Kia/Hyundai proportions.
- **Temporal alignment.** We assume all cities report on the same calendar month boundaries.
- **VICE data completeness.** The Motherboard dataset represents FOIA-obtained records that may not cover all jurisdictions or all time periods.

### Did you filter any data without labeling it?

No. Every filter applied is explicitly labeled:

- The stacked bar chart title states "Top 10 Cities" so the audience knows a filter was applied.
- The geographic dataset footnote documents how many agencies were excluded due to missing data (e.g., "N=12 agencies excluded due to missing 2020 data").
- All time-series charts clearly label the date range (January 2019 – January 2023). No data outside this range was available or silently excluded.

### How was your data sourced and verified for credibility?

| Dataset | Source | Verification Method |
|---------|--------|-------------------|
| Milwaukee Monthly | Milwaukee Police Department public crime statistics | Government primary source; cross-referenced with city council meeting minutes |
| Multi-City | Compiled from individual city police department reports | Secondary compilation; spot-checked against original department press releases |
| Geographic (UCR) | FBI Uniform Crime Reporting program | Federal government primary source; standard law enforcement reporting system |
| VICE/Motherboard | FOIA requests by Motherboard journalists | Journalism-sourced; verified through FOIA documentation trail; published by established news organization |

### Was your data acquired in an ethical way?

Yes. All data was acquired through legitimate, transparent channels:

- Government data was obtained through standard public records access—no ethical concerns.
- VICE/Motherboard data was obtained through Freedom of Information Act requests, which is a legal mechanism specifically designed for public accountability.
- No web scraping of private data, no surveillance data, and no data purchased from brokers was used.
- All sources are clearly cited in the final deliverable.

### How would you mitigate the ethical implications identified?

| Risk | Mitigation Strategy |
|------|-------------------|
| Copycat encouragement | The presentation does not describe specific theft methods or techniques. A disclaimer notes that the vulnerability has been addressed through manufacturer recalls and software updates. |
| Brand stigmatization | The narrative is framed around a systemic design vulnerability and its resolution rather than brand shaming. The call to action acknowledges the manufacturer's recall and patch response. |
| Ecological fallacy | A footnote states: "City-level totals may not reflect uniform risk across all neighborhoods within a city." |
| Correlation ≠ causation | Hedging language is used throughout: "coinciding with" rather than "caused by." The timeline annotation reads "Kia Boyz trend onset" (observed timing) rather than attributing causation to any single factor. |
| Incomplete coverage | The presentation documents: "This analysis includes only agencies reporting to the FBI UCR system. Actual national totals may be higher." |
| Filtered data | Every filter is labeled directly in chart titles or footnotes. No silent exclusions exist anywhere in the presentation. |

---
