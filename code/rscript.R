# ============================================================
# Blog Post 4: Does Population Growth Bring Prosperity?
# Data source: FRED (Federal Reserve Economic Data)
install.packages("here")
library(tidyverse)   # dplyr, tidyr, ggplot2, readr
library(fredr)       # FRED API
library(here)        # here()
fredr_set_key(Sys.getenv("FRED_API_KEY"))
# ============================================================

state_codes <- c(
  "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
  "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
  "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
  "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
  "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY")
pop_data <- map_dfr(state_codes, function(st) {
  fredr(
    series_id = paste0(st, "POP"),
    observation_start = as.Date("2000-01-01"),
    observation_end = as.Date("2025-12-31")
  ) |>
    mutate(state = st, variable = "population")
})

inc_data <- map_dfr(state_codes, function(st) {
  fredr(
    series_id = paste0(st, "PCPI"),
    observation_start = as.Date("2000-01-01"),
    observation_end = as.Date("2025-12-31")
  ) |>
    mutate(state = st, variable = "income_per_capita")
})

all_data <- bind_rows(pop_data, inc_data)

dir.create(here("data", "raw"), recursive = TRUE, showWarnings = FALSE)
write_csv(all_data, here("data", "raw", "fred_states_raw.csv"))

# ============================================================
wide_data <- all_data |>
  select(date, state, variable, value) |>
  pivot_wider(names_from = variable, values_from = value)

wide_data |>
  group_by(state) |>
  summarise(n = n(), .groups = "drop") |>
  filter(n != 26)

dir.create(here("data", "clean"), recursive = TRUE, showWarnings = FALSE)
write_csv(wide_data, here("data", "clean", "states_panel.csv"))

# ============================================================

growth <- wide_data |>
  group_by(state) |>
  summarise(
    pop_2000 = population[date == min(date)],
    pop_2025 = population[date == max(date)],
    inc_2000 = income_per_capita[date == min(date)],
    inc_2025 = income_per_capita[date == max(date)],
    .groups = "drop"
  ) |>
  mutate(
    pop_growth = (pop_2025 / pop_2000 - 1) * 100,
    inc_growth = (inc_2025 / inc_2000 - 1) * 100
  ) |>
  arrange(desc(pop_growth))

write_csv(growth, here("data", "clean", "states_growth.csv"))

print(growth, n = 51)

# ============================================================
# fast
p1_top <- growth |>
  slice_max(pop_growth, n = 15) |>
  mutate(state = reorder(state, pop_growth)) |>
  ggplot(aes(x = pop_growth, y = state)) +
  geom_col(fill = "#2c7fb8") +
  geom_text(aes(label = round(pop_growth, 1)), hjust = -0.3, size = 3.5) +
  labs(
    title = "Which States Grew Fastest, 2000–2025?",
    subtitle = "Top 15 states by population growth",
    x = "Population growth (%)",
    y = NULL,
    caption = "Data source: FRED (state population estimates)"
  ) +
  theme_minimal(base_size = 13) +
  expand_limits(x = max(growth$pop_growth) * 1.15)

p1_top

# slow
p1_bottom <- growth |>
  slice_min(pop_growth, n = 10) |>
  mutate(state = reorder(state, pop_growth)) |>
  ggplot(aes(x = pop_growth, y = state)) +
  geom_col(fill = "#d7191c") +
  geom_text(aes(label = round(pop_growth, 1)), hjust = 0.3, size = 3.5) +
  labs(
    title = "Which States Shrank or Stagnated?",
    subtitle = "Bottom 10 states by population growth",
    x = "Population growth (%)",
    y = NULL,
    caption = "Data source: FRED (state population estimates)"
  ) +
  theme_minimal(base_size = 13) +
  expand_limits(x = min(growth$pop_growth) * 1.15)

p1_bottom

# ============================================================

p2 <- growth |>
  ggplot(aes(x = pop_growth, y = inc_growth)) +
  geom_point(size = 3, color = "#2c7fb8", alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "#d7191c", linetype = "dashed") +
  geom_text(aes(label = state), vjust = -1, size = 3, alpha = 0.8) +
  labs(
    title = "Does Population Growth Come With Income Growth?",
    subtitle = "Each point is a U.S. state, 2000–2025",
    x = "Population growth (%)",
    y = "Income per capita growth (%)",
    caption = "Data source: FRED (state population and per capita personal income)"
  ) +
  theme_minimal(base_size = 13)

p2

# ============================================================
top_states <- growth |> slice_max(pop_growth, n = 6) |> pull(state)
bottom_states <- growth |> slice_min(pop_growth, n = 6) |> pull(state)

grouped_states <- wide_data |>
  filter(state %in% c(top_states, bottom_states)) |>
  mutate(
    group = if_else(state %in% top_states, "Fast-growing", "Slow-growing")
  )

p3 <- grouped_states |>
  ggplot(aes(x = date, y = income_per_capita, color = state)) +
  geom_line(linewidth = 1.1) +
  facet_wrap(~ group, ncol = 2, scales = "free_y") +
  labs(
    title = "Income Trajectories: Fast-Growing vs Slow-Growing States",
    subtitle = "Per capita personal income, 2000–2025",
    x = NULL,
    y = "Per capita income (USD)",
    color = "State",
    caption = "Data source: FRED (state per capita personal income)"
  ) +
  theme_minimal(base_size = 12)

p3

# ============================================================

dir.create(here("output"), recursive = TRUE, showWarnings = FALSE)

ggsave(here("output", "pop_growth_top.png"), plot = p1_top,
       width = 8, height = 6, dpi = 300)

ggsave(here("output", "pop_growth_bottom.png"), plot = p1_bottom,
       width = 8, height = 6, dpi = 300)

ggsave(here("output", "pop_vs_income.png"), plot = p2,
       width = 9, height = 6, dpi = 300)

ggsave(here("output", "income_trajectories.png"), plot = p3,
       width = 9, height = 6, dpi = 300)
