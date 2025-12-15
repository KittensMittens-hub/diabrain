library(readxl)
library(dplyr)
library(tidyr)
library(gtsummary)
df_p3 <- read_excel("diabrain.xlsx")
df_p3 <- df_p3 %>%
  select(1, 50:71, -65) %>% #столбец 65 странный, удалить?
  mutate(across(c(2:12, 17:22), ~ round(as.numeric(.), 2)),  # преобразуем переменные в numeric или factor в соответствии со спецификацией
         across(c(1, 13:16), as.factor)) 
summary(df_p3) #посмотрим данные
df_p3 <- df_p3 %>%
  mutate(Height = if_else(Height == 1, NA, Height), # у пациента с номером 215 рост 1, заменяем на NA
         `BMI 0` = if_else(`BMI 0` == 0, NA, `BMI 0`), # у пациента с номером 215 ИМТ 0, заменяем на NA
         `BMI 6` = if_else(`BMI 6` == 0, NA, `BMI 6`),
         `BMI 12` = if_else(`BMI 12` == 45770, 23.40, `BMI 12`), # значение было записано, как дата, при преобразовании в формат numeric сломалось
         `Creatinine 6` = if_else(`ID` == 198, 111, `Creatinine 6`), # у пациента 198 есть значения креатинина 1,11, заменяем на 111
         `GFR 6` = if_else(`ID` == 184, 101, `GFR 6`), # уточнено значение по ПМД
         `GFR 6` = if_else(`ID` == 198, 68, `GFR 6`), # уточнено значение по ПМД
         `GFR 12` = if_else(`ID` == 250, NA, `GFR 6`)) # уточнено значение по ПМД
summary(df_p3) #посмотрим данные еще раз

tbl_summary(df_p3 %>% select(-ID))