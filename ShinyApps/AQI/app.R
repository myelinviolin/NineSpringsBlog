library(shiny)
library(gt)
library(magrittr)
library(dplyr)

aqi <- read.table(
  file = "https://www.airnowapi.org/aq/observation/zipCode/current/?format=text/csv&zipCode=53713&distance=25&API_KEY=223DC9F5-E09A-4A38-A9A4-B6737BA465D2",
  sep = ",", header = TRUE) 
date <- lubridate::as_date(aqi$DateObserved[1]) %>% lubridate::ymd() %>% format("%d %b %Y")
time <- aqi$HourObserved[1] %>% as.character() %>% paste0(":00")
date_time <- paste(date, time)

aqi %<>% dplyr::select(ParameterName, AQI, CategoryName)

colnames(aqi) %<>% dplyr::recode("CategoryName" = "Category", "ParameterName" = "Parameter")

palette <- scales::col_bin(palette = c("#00E400", "#FFFF00", "#FF7E00", "#FF0000", "#8F3F97", "#7E0023"),
                           bins = c(0, 50, 100, 150, 200, 300, 500))

aqi_table <- gt(aqi) %>%
  tab_header(title = "Current Air Quality in South Madison, WI", 
             subtitle = date_time) %>%
  data_color(columns = "AQI", fn = palette, target_columns = everything())


ui <- fluidPage(
  mainPanel(
    gt_output("table")
  )
)

server <- function(input, output) {
  output$table <- render_gt(aqi_table)
}

# Run the application 
shinyApp(ui = ui, server = server)
