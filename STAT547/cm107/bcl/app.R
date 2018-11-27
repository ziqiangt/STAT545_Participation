library(shiny)
library(tidyverse)

a <- 5
print(a^2)
bcl <- read.csv("http://pub.data.gov.bc.ca/datasets/176284/BC_Liquor_Store_Product_Price_List.csv",stringsAsFactors = FALSE)
# Define UI for application that draws a histogram
ui <- fluidPage(
  
  ## Layouts: Together - panel
  titlePanel("BC Liquor price app", 
             windowTitle = "BCL app"),
  sidebarLayout(
    sidebarPanel(sliderInput("priceInput", "Select your desired price range.",
                             min = 0, max = 100, value = c(15, 30), pre="$"),
                 
                 radioButtons("typeInput", " Select one type of beverage.",
                              choices = c("BEER", "REFRESHMENT", "SPIRITS", "WINE"),
                              selected = "WINE")),
    mainPanel(
      plotOutput("price_hist"),
      tableOutput("price_table"))
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  observe(print(input$priceInput))
   bcl_filtered <- reactive({
     bcl %>% 
      filter(Price < input$priceInput[2],
             Price > input$priceInput[1],
             Type == input$typeInput)
  })
  
   
  output$price_hist <- renderPlot({
    bcl_filtered() %>% 
      ggplot(aes(Price)) +
      geom_histogram()
  })
  
  output$price_table <- renderTable({
    bcl_filtered()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

