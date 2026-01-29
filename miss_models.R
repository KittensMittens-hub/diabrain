
# Settings ----------------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse)
  library(patchwork)
  library(marginaleffects)
  library(mice)
})

seed <- 31683

set.seed(seed)

theme_set(
  theme_bw(base_size = 14, base_family = "Arimo") +
    theme(
      axis.text.y = element_text(size = 13, color = "black"),
      axis.text.x = element_text(size = 13, color = "black"),
      legend.text = element_text(size = 14),
      strip.text = element_text(size = 14),
      panel.grid.major.x = element_blank(),
      axis.ticks.x = element_blank()
    )
)

pd <- position_dodge(0.25)


# Data preporcessing ------------------------------------------------------
df <- read_rds("clean_data/diabrain.rds")

# nrow(df) == n_distinct(df$ID)

df <- df |> 
  select(
    ID, Treatment,
    Age, Sex, `DM duration`,
    `BMI 0`, `GFR0`, `NSE 0`, `Lchains 0`, `S100 0`,`MOCA 0`, `MMSE 0`,
    `HbA1c 0`, `HbA1c 3`, `HbA1c 6`, `HbA1c 9`, `HbA1c 12`
  ) |> 
  rename(`GFR 0` = `GFR0`) |> 
  rename_with(function(x) {
    str_squish(x) |>
      str_replace("\\s", "_")
  }) |>
  mutate(log_DM_duration = log(DM_duration)) 

group_cols <- c("#4472C4", "#ED7D31", "grey45") |>
  set_names(levels(df$Treatment))

# md.pattern(select(df, -c(ID, Treatment)))

df_long <- df |> 
  filter(Treatment != "метформин") |> 
  mutate(Treatment = fct_drop(Treatment)) |> 
  pivot_longer(
    starts_with("HbA1c_"),
    names_to = "time",
    names_transform = \(x) as.factor(as.integer(str_extract(x, "\\d+$")))
  ) |> 
  arrange(Treatment, time)

# Complete case analysis --------------------------------------------------
df_long_cc <- df_long |> 
  drop_na(c(
    Age, Sex, BMI_0, GFR_0
  ))

## Model for Metformin ----
fit_met <- lm(
  HbA1c_0 ~ Treatment * (Age + Sex + log_DM_duration + BMI_0 + GFR_0),
  data = df
)

### "counterfactual" grid
grid_met <- df |> 
  filter(Treatment != "метформин") |> 
  mutate(Treatment = "метформин") 

### "counterfactual" mean
pred_met <- marginaleffects::avg_predictions(
  fit_met, 
  newdata = grid_met, 
  vcov = "HC4"
) |>
  as_tibble()

## Longitudinal model without Metformin ----
fit_gee_cc <- geepack::geeglm(
  value ~ (Treatment * time) * (Age + Sex + log_DM_duration + BMI_0 + GFR_0),
  id = ID,
  data = df_long_cc,
  family = "gaussian",
  corstr = "independence"
)

### longitudinal "counterfactual" grid
grid_cc <- marginaleffects::datagrid(
  model = fit_gee_cc, 
  Treatment = levels(df_long_cc$Treatment),
  grid_type = "counterfactual"
)

### longitudinal "counterfactual" means
pred_cc <- marginaleffects::avg_predictions(
  fit_gee_cc,
  newdata = grid_cc,
  by = c("time", "Treatment")
)

### Mean difference by time
effect_cc <- marginaleffects::avg_comparisons(
  fit_gee_cc,
  newdata = grid_cc,
  variables = "Treatment", 
  by = "time",
  comparison = "difference"
)

pred_cc |>
  as_tibble() |>
  ggplot(aes(time, estimate, group = Treatment, color = Treatment)) +
  geom_line(linewidth = 0.8, alpha = 0.5) +
  geom_errorbar(
    aes(ymin = conf.low, ymax = conf.high),
    position = pd, linewidth = 0.8, width = 0.1
  ) +
  geom_point(position = pd, color = "white", size = 3) +
  geom_point(position = pd, size = 2) +
  scale_color_manual(values = group_cols) +
  scale_y_continuous(name = "HbA1c", n.breaks = 8) 

effect_cc |>
  as_tibble() |>
  ggplot(aes(time, estimate, group = 1)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey55") +
  geom_line(linewidth = 0.8, alpha = 0.5) +
  geom_errorbar(
    aes(ymin = conf.low, ymax = conf.high),
    linewidth = 0.8, width = 0.1
  ) +
  geom_point(color = "white", size = 3) +
  geom_point(size = 2) +
  scale_y_continuous(name = "SGLT2i − GLP1")

### Difference with Metformin
pred_cc |>
  as_tibble() |>
  transmute(
    time, Treatment,
    estimate = estimate - pred_met$estimate,
    std.error = sqrt(std.error^2 + pred_met$std.error^2),
    statistic = estimate / std.error,
    conf.low = estimate - (qnorm(0.975) * std.error),
    conf.high = estimate + (qnorm(0.975) * std.error),
    p.value = 2 * pnorm(abs(statistic), lower.tail = FALSE)
  )

# MICE --------------------------------------------------------------------
m <- 10
it <- 10

## Imputation for Metformin ----
imp_met <- mice::mice(
  data = df,
  formulas = list(
    # Treatment * (Age + Sex + BMI_0 + GFR_0)
    "BMI_0" = BMI_0 ~ Treatment * (Age + Sex + log_DM_duration + GFR_0),
    "GFR_0" = GFR_0 ~ Treatment * (Age + Sex + log_DM_duration + BMI_0)
  ),
  m = m, maxit = it, seed = seed, 
  printFlag = FALSE
)

## Models for Metformin ----
fits_met <- map(seq_len(m), function(i) {
  d <- mice::complete(imp_met, i)
  fit <- lm(
    HbA1c_0 ~ Treatment * (Age + Sex + log_DM_duration + BMI_0 + GFR_0),
    data = d
  )
  grid_met <- d |> 
    filter(Treatment != "метформин") |> 
    mutate(Treatment = "метформин") 
  
  marginaleffects::avg_predictions(
    fit, 
    newdata = grid_met, 
    vcov = "HC4"
  )
})

### pooled "counterfactual" mean
fits_met <- mice::pool(fits_met, dfcom = Inf)$pooled |>
  transmute(
    estimate,
    std.error = sqrt(t),
    conf.low = estimate - (qnorm(0.975) * std.error),
    conf.high = estimate + (qnorm(0.975) * std.error)
  )

## Imputation for longitudinal data ----
df_for_mi <- df |> 
  filter(Treatment != "метформин") |> 
  mutate(Treatment = fct_drop(Treatment)) 

imp_wide <- mice::mice(
  data = df_for_mi,
  formulas = list(
    "BMI_0" = BMI_0 ~ Treatment * (Age + Sex + log_DM_duration + GFR_0 + HbA1c_0 + HbA1c_3 + HbA1c_6 + HbA1c_9 + HbA1c_12),
    "GFR_0" = GFR_0 ~ Treatment * (Age + Sex + log_DM_duration + BMI_0 + HbA1c_0 + HbA1c_3 + HbA1c_6 + HbA1c_9 + HbA1c_12),
    "HbA1c_3" = HbA1c_3 ~ Treatment * (Age + Sex + log_DM_duration + BMI_0 + GFR_0 + HbA1c_0 + HbA1c_6 + HbA1c_9 + HbA1c_12),
    "HbA1c_6" = HbA1c_6 ~ Treatment * (Age + Sex + log_DM_duration + BMI_0 + GFR_0 + HbA1c_0 + HbA1c_3 + HbA1c_9 + HbA1c_12),
    "HbA1c_9" = HbA1c_9 ~ Treatment * (Age + Sex + log_DM_duration + BMI_0 + GFR_0 + HbA1c_0 + HbA1c_3 + HbA1c_6 + HbA1c_12),
    "HbA1c_12" = HbA1c_12 ~ Treatment * (Age + Sex + log_DM_duration + BMI_0 + GFR_0 + HbA1c_0 + HbA1c_3 + HbA1c_6 + HbA1c_9)
  ),
  m = m, maxit = it, seed = seed, 
  printFlag = FALSE
)

imp_long <- lapply(seq_len(m), function(i) {
  mice::complete(imp_wide, i) |>
    pivot_longer(
      starts_with("HbA1c_"),
      names_to = "time",
      names_transform = \(x) as.factor(as.integer(str_extract(x, "\\d+$")))
    ) |> 
    mutate(log_DM_duration = log(DM_duration))
})

## Longitudinal models without Metformin ----
fit_gee_mice <- map(seq_len(m), function(i) {
  d <- imp_long[[i]]
  geepack::geeglm(
    value ~ (Treatment * time) * (Age + Sex + log_DM_duration + BMI_0 + GFR_0),
    id = ID,
    data = d,
    family = "gaussian",
    corstr = "independence"
  )
})

### longitudinal "counterfactual" means
pred_mice <- map(seq_len(m), function(i) {
  grid <- marginaleffects::datagrid(
    model = fit_gee_mice[[i]], 
    Treatment = levels(imp_long[[i]]$Treatment),
    grid_type = "counterfactual"
  )
  marginaleffects::avg_predictions(
    fit_gee_mice[[i]],
    newdata = grid,
    by = c("time", "Treatment")
  )
})

pred_mice <- map2(
  pred_mice[[1]]$time,
  pred_mice[[1]]$Treatment,
  function(x, y) {
    map(pred_mice, function(d) {
      d |>
        filter(time == x & Treatment == y)
    }) |>
      mice::pool(dfcom = Inf) |>
      _[["pooled"]] |>
      transmute(
        time = x,
        Treatment = y,
        estimate,
        std.error = sqrt(t),
        conf.low = estimate - (qnorm(0.975) * std.error),
        conf.high = estimate + (qnorm(0.975) * std.error)
      )
  }
) |>
  reduce(bind_rows)

### Mean difference by time
effect_mice <- map(seq_len(m), function(i) {
  grid <- marginaleffects::datagrid(
    model = fit_gee_mice[[i]], 
    Treatment = levels(imp_long[[i]]$Treatment),
    grid_type = "counterfactual"
  )
  marginaleffects::avg_comparisons(
    fit_gee_mice[[i]],
    newdata = grid,
    variables = "Treatment", 
    by = "time",
    comparison = "difference"
  )
})

effect_mice <- map(
  effect_mice[[1]]$time,
  function(x) {
    map(effect_mice, function(d) {
      d |>
        filter(time == x)
    }) |>
      mice::pool(dfcom = Inf) |>
      _[["pooled"]] |>
      transmute(
        time = x,
        estimate,
        std.error = sqrt(t),
        statistic = estimate / std.error,
        conf.low = estimate - (qnorm(0.975) * std.error),
        conf.high = estimate + (qnorm(0.975) * std.error),
        p.value = 2 * pnorm(abs(statistic), lower.tail = FALSE)
      )
  }
) |>
  reduce(bind_rows)

pred_mice |>
  as_tibble() |>
  ggplot(aes(time, estimate, group = Treatment, color = Treatment)) +
  geom_line(linewidth = 0.8, alpha = 0.5) +
  geom_errorbar(
    aes(ymin = conf.low, ymax = conf.high),
    position = pd, linewidth = 0.8, width = 0.1
  ) +
  geom_point(position = pd, color = "white", size = 3) +
  geom_point(position = pd, size = 2) +
  scale_color_manual(values = group_cols) +
  scale_y_continuous(name = "HbA1c", n.breaks = 8) 

effect_mice |>
  as_tibble() |>
  ggplot(aes(time, estimate, group = 1)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey55") +
  geom_line(linewidth = 0.8, alpha = 0.5) +
  geom_errorbar(
    aes(ymin = conf.low, ymax = conf.high),
    linewidth = 0.8, width = 0.1
  ) +
  geom_point(color = "white", size = 3) +
  geom_point(size = 2) +
  scale_y_continuous(name = "SGLT2i − GLP1")

### Difference with Metformin
pred_mice |>
  as_tibble() |>
  transmute(
    time, Treatment,
    estimate = estimate - fits_met$estimate,
    std.error = sqrt(std.error^2 + fits_met$std.error^2),
    statistic = estimate / std.error,
    conf.low = estimate - (qnorm(0.975) * std.error),
    conf.high = estimate + (qnorm(0.975) * std.error),
    p.value = 2 * pnorm(abs(statistic), lower.tail = FALSE)
  )
