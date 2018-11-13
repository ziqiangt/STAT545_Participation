library(shiny)

a <- 5
print(a^2)
bcl <- read.csv("/Users/apple/Desktop/STAT545/STAT545_Participation/STAT547/cm107/bcl/bcl-data.csv")

# Define UI for application that draws a histogram
ui <- fluidPage(
  "This is some text",
  p("This is more text"),
  tags$h1("Level 1 header, part1"),
  h1(em("Level 1 header, part2")),
  tags$b("This text is bold."),
  br(),
  tags[["b"]]("This text is bold."),
  HTML("<h1>Level 1 header, part3</h1>"),
  tags$div(`data-value` = "test"),
  tags$a(href="www.rstudio.com", "Click here!"),
  tags$audio(src = "sound.mp3", type = "audio/mp3", autoplay = NA, controls = NA),
  tags$blockquote("Tidy data sets are all the same. Each messy data set is messy in its own way.", cite = "Hadley Wickham"),
  
  ## Layouts: Together - panel
  titlePanel("BC Liquor price app", 
             windowTitle = "BCL app"),
  sidebarLayout(
    sidebarPanel("This text is in the sidebar."),
    mainPanel(
      plotOutput("price_hist"),
      tableOutput("price_table"))
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  output$price_hist <- renderPlot(ggplot2::qplot(bcl$Price, bins = 30))
  output$price_table <- renderTable(bcl)
}

# Run the application 
shinyApp(ui = ui, server = server)

