# Blog4: Does Population Growth Bring Prosperity?

An analysis of population and income trends across U.S. states,
2000–2025, using data from the Federal Reserve Economic Data
(FRED) system.

## Research Question

**Does population growth bring economic prosperity? Or are
Americans moving to states that are cheaper, not richer?**

This question matters for anyone thinking about where to live,
work, or invest — and for policymakers trying to understand
why some regions grow while others stagnate.

## Data Source

| Item | Description |
|------|-------------|
| Source | [FRED](https://fred.stlouisfed.org/) (Federal Reserve Bank of St. Louis) |
| Coverage | 50 U.S. states + District of Columbia |
| Years | 2000–2025 (annual) |
| Observations | ~2,650 (51 states × 26 years × 2 variables) |
| Access | Programmatic via the `fredr` R package |

### Variables Used

| Variable | FRED Series ID | Unit |
|----------|---------------|------|
| Population | `{state}POP` | Thousands |
| Per capita personal income | `{state}PCPI` | Current USD |

Per capita income is used instead of total income to make
comparisons between states of different sizes meaningful.

## Repository Structure

```
blog4/
├── data/
│   └── clean/
│       ├── states_panel.csv          # Wide-format panel data
│       └── states_growth.csv         # Growth rates, 2000–2025
├── code/
│   └── state_growth_analysis.R       # Full analysis script
├── output/
│   ├── pop_growth.png
│   ├── pop_vs_income.png
│   └── income_trajectories.png
│   └── Blog4.rmd  # Blog post
└── README.md
```

## How to Reproduce

1. Clone this repository
2. Set up your FRED API key:
   ```r
   usethis::edit_r_environ()
   # Add: FRED_API_KEY=your_key_here
   # Restart R
   ```
3. Install required packages:
   ```r
   install.packages(c("tidyverse", "fredr", "here"))
   ```
4. Run:
   ```r
   source("code/state_growth_analysis.R")
   ```

## Key Findings

1. **Migration cannot be considered as a weatherwane for income per capita**
   Nevada, Georgia, and Delaware all grew quickly but had some
   of the slowest income growth in the country. Meanwhile, Illinois and New York have high and rising per capita
   incomes. They are losing residents to cheaper places, not
   to more productive ones.

2. **Income growth is not driven by population.** The two
   variables are nearly uncorrelated across states and over
   time. What actually drives income growth — industry mix,
   education levels, productivity — is a separate question.

## Methodology Notes

- **Per capita, not total.** Total income is dominated by
  state size; per capita measures the average person's income.
- **Growth rates.** Computed as `(value_2025 / value_2000 - 1) × 100`.
- **No cost-of-living adjustment.** A dollar in Mississippi
  buys more than a dollar in California, but this analysis
  treats them as equal. This is a known limitation.
- **Annual frequency.** FRED provides annual state-level
  estimates between decennial censuses.

## Data Attribution

All data comes from FRED:

> U.S. Bureau of Economic Analysis and U.S. Census Bureau,
> retrieved from FRED, Federal Reserve Bank of St. Louis,
> https://fred.stlouisfed.org/, September 2026.

