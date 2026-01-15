library(readxl)
library(tidyverse)

data <- read_excel("diabrain.xlsx")


#ЧАСТЬ 1. Очистка данных столбцы Treatment до TG 12 (триглицериды 12 мес) включительно 

data <- data %>%
  mutate(Treatment = recode(Treatment,
                            "1" = "метформин",
                            "2" = "SGLT2i",
                            "3" = "SGLT2i", 
                            "7" = "SGLT2i",
                            "4" = "GLP1",
                            "51" = "GLP1",
                            "52" = "GLP1",
                            "6" = "GLP1",
                            "5" = "GLP1",
                            "8" = "GLP1"
  )) 


data$Age[is.na(data$Age)] <- "69"
data <- data %>% 
  mutate(Age = as.numeric(Age))


data$Treatment <- as.factor(data$Treatment)
data$Sex <- as.factor(data$Sex)


data$`HbA1c level` <- as.factor(data$`HbA1c level`)


replacement_df <- data.frame(
  ID = c(136, 149, 154, 163, 215, 231, 238),
  New_DM_Duration = c(10, 8, 16, 8, 6, 10, 7)
)


data <- data %>%
  left_join(replacement_df, by = "ID") %>%
  mutate(`DM duration` = ifelse(is.na(`DM duration`) & !is.na(New_DM_Duration), 
                                New_DM_Duration, 
                                `DM duration`)) %>%
  select(-New_DM_Duration) 


data$`DM duration`[data$`DM duration` == 0] <- 1


data$`HbA1c 0`[data$`HbA1c 0` == 45327.0] <- 6
data$`HbA1c 0`[data$`HbA1c 0` == NA] <- 10

data <- data %>%
  mutate(`HbA1c 0` = replace(`HbA1c 0`, is.na(`HbA1c 0`), 10))


data$`HbA1c 6` <- as.numeric(data$`HbA1c 6`)


data$`HbA1c 9` <- as.numeric(data$`HbA1c 9`)

data$`HbA1c 9`[data$`HbA1c 9` == 45296.0] <- 5
data$`HbA1c 9`[data$`HbA1c 9` == 45298.0] <- 6.5


data$`HbA1c 12` <- as.numeric(data$`HbA1c 12`)
data$`HbA1c 12`[data$`HbA1c 12` == 45298.0] <- 6.0


data$`S100 0`[data$`S100 0` == 0.02] <- 20
data$`S100 0`[data$`S100 0` == 0.03] <- 30

data$`S100 3`[data$`S100 3` == 0.03] <- 30

data$`S100 6`[data$`S100 6` == 0.05] <- 50

data$`S100 12`[data$`S100 6` == 0.01] <- 10

data$`LDL 0` <- as.numeric(data$`LDL 0`)

data$`TG 0` <- as.numeric(data$`TG 0`)

hrt_index <- which(colnames(data) == "HRT")

if (length(hrt_index) > 0) {
  
  data_1 <- data[, 1:(hrt_index - 1), drop = FALSE]
} else {
  warning("Столбец 'HRT' не найден")
  data_1 <- data
}



## ЧАСТЬ 2. Очистка данных столбцы HRT (заместительная гормональная терапия) до Anticoagulants включительно 

# В процессе анализа данных найдены следующие ошибки:
# 1) 152 пациент в Сardiac ischemia имеет значение 3
# 2) 205 пациент в Alcohol иммет значение 2
# 3) 266 пациет в Anticoagulants имеет -
# 4) 127, 179, 181, 222 пациенты в Hypertension duration имеют значения 'NAP'
# 5) 215 пациент Hypertension = 0 (нет гипертонии), но Hypertension duration = 10
# 6) 142, 168 пациенты Hypertension = 1 (есть гипертония), но Hypertension duration = 0
# 
# 
# В процессе подготовки базу данных изменили следущим образом:
#   
#   1) Заменили значение Сardiac ischemia пациента 152 с 3 на 0 (нет ишемической болезни сердца)
# 2) Заменили значение Alcohol пациента 205 с 2 на 1 (употребление алкоголя)
# 3) Заменили значени Anticoagulants 266 пациента с '-' на NA (пропущенное значение)
# 4) Заменили значения Hypertension duration 127, 179, 181 и 222 пациентов с 'NAP' на NA (пропущенные значения)
# 5) Заменили значение Hypertension 215 пациента с 0 на 1 (есть гипертония)
# 6) Заменили значения Hypertension duration 142 и 168 пациентов с 0 на NA
# 
# 7) Переменные HRT, Hypertension, `Сardiac ischemia`, Stroke, Polineuropathy, Retinopathy, Smoking, Alcohol, `ACE inhibitors`, ARB, BB, `Calcium channel blockers`, Aspirin, Diuretics, Statin, Anticoagulants перведены в фактор
# 8) Переменная Hypertension duration преведена в числовой (numeric) тип
# 
# 9) При Hypertension равной 0 (отсутствие гипертонии) пропущенные значения Hypertension duration заменили на 0


#Замена некорректных значений
data$`Сardiac ischemia`[data$ID == 152] <- 0

data$Alcohol[data$ID == 205] <- 1

data$Anticoagulants[data$ID == 266] <- NA

data$`Hypertension duration`[data$ID %in% c(127, 179, 181, 222)] <- NA

data$Hypertension[data$ID == 215] <- 1

data$`Hypertension duration`[data$ID %in% c(142, 168)] <- NA


#Изменения типов переменных
data <- data %>% 
  mutate(
    across(c(HRT, Hypertension, `Сardiac ischemia`, Stroke, Polineuropathy, Retinopathy, Smoking, Alcohol, `ACE inhibitors`, ARB, BB, `Calcium channel blockers`, Aspirin, Diuretics, Statin, Anticoagulants), ~as.factor(.)),
    `Hypertension duration` = as.numeric(`Hypertension duration`)
  )


#Пропущенные значения длительности гипертонии заменяем на 0 если диагноза гипертонии не стоит
data <- data %>% 
  mutate(
    `Hypertension duration` = case_when(
      Hypertension == 0 & is.na(`Hypertension duration`) ~ 0,
      TRUE ~ `Hypertension duration`
    )
  )


data_2 <- subset(data, select = c("ID", "HRT", "Hypertension", 
                                  "Hypertension duration", "Сardiac ischemia", 
                                  "Stroke", "Polineuropathy", "Retinopathy", 
                                  "Smoking", "Alcohol", "ACE inhibitors", 
                                  "ARB", "BB", "Calcium channel blockers", 
                                  "Aspirin", "Diuretics", "Statin", 
                                  "Anticoagulants"))




##ЧАСТЬ 3. Очистка данных столбцы Height до до GFR 12 (скорость клубочковой фильтрации) вкючительно 

df_p3 <- read_excel("diabrain.xlsx")
df_p3 <- df_p3 %>%
  select(1, 50:71, -65) %>% #столбец 65 странный, удалить?
  mutate(across(c(2:12, 17:22), ~ round(as.numeric(.), 2)),  # преобразуем переменные в numeric или factor в соответствии со спецификацией
         across(c(1, 13:16), as.factor)) 

# summary(df_p3) #посмотрим данные

df_p3 <- df_p3 %>%
  mutate(Height = if_else(Height == 1, NA, Height), # у пациента с номером 215 рост 1, заменяем на NA
         `BMI 0` = if_else(`BMI 0` == 0, NA, `BMI 0`), # у пациента с номером 215 ИМТ 0, заменяем на NA
         `BMI 6` = if_else(`BMI 6` == 0, NA, `BMI 6`),
         `BMI 12` = if_else(`BMI 12` == 45770, 23.40, `BMI 12`), # значение было записано, как дата, при преобразовании в формат numeric сломалось
         `Creatinine 6` = if_else(`ID` == 198, 111, `Creatinine 6`), # у пациента 198 есть значения креатинина 1,11, заменяем на 111
         `GFR 6` = if_else(`ID` == 184, 101, `GFR 6`), # уточнено значение по ПМД
         `GFR 6` = if_else(`ID` == 198, 68, `GFR 6`), # уточнено значение по ПМД
         `GFR 12` = if_else(`ID` == 250, NA, `GFR 6`)) # уточнено значение по ПМД

# summary(df_p3) #посмотрим данные еще раз

df_p3$ID <- as.numeric(df_p3$ID)




# ЧАСТЬ 4. Очистка данных столбцы MOCA 0 - Beck anxiety 12. (Все шкалы неврологического дефицита)

file_path <- "diabrain.xlsx"
df_brain <- read_excel(file_path)

moca_start <- 72
df_moca <- df_brain[, moca_start:ncol(df_brain)]

df_moca <- df_brain %>%
  select(ID, Treatment, moca_start:ncol(df_brain))


df_moca <- df_moca %>%
  mutate(Treatment = recode(Treatment,
                            "1" = "метформин",
                            "2" = "SGLT2i",
                            "3" = "SGLT2i", 
                            "7" = "SGLT2i",
                            "4" = "GLP1",
                            "51" = "GLP1",
                            "52" = "GLP1",
                            "6" = "GLP1",
                            "5" = "GLP1",
                            "8" = "GLP1"
  )) 

df_moca <- df_moca %>%
  mutate(across(
    c(`MOCA 0`, `MOCA 3`, `MOCA 6`, `MOCA 9`, `MOCA 12`),
    ~ ifelse(. == 0, NA, .)
  ))

df_moca <- df_moca %>%
  mutate(across(
    where(is.character) & !matches("^Treatment$"),
    ~ suppressWarnings(as.numeric(gsub(",", ".", .)))
  ))

df_num <- df_moca[, sapply(df_moca, is.numeric)]

df_moca1 <- df_moca %>%
  select(-Treatment)




## ОБЪЕДИНЕНИЕ четырех очищенных частей данных

merged_data <- data_1 %>%
  left_join(data_2, by = "ID") %>%
  left_join(df_p3, by = "ID") %>% 
  left_join(df_moca, by = "ID")




##СОХРАНЕНИЕ ИТОГОВОГО ФАЙЛА
saveRDS(merged_data, file = "data.rds")


