library(shiny)

# Define UI 
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Indianapolis 8 Hr. Ozone and Weather Data"),
  
  # Sidebar with controls to select years and monitor
  sidebarPanel(
    
    sliderInput("years", "Years:",
                min = 2007, max = 2011, value = c(2007,2011), format="####"),
    
    selectInput("monitor", "Monitor:",
                list("Harding St." = "harding",
                     "E. 16th St." = "east.16th",
                     "Ft. Harrison" = "ft.harison"))
    
    
),
  
  # Main panel with tabs
  mainPanel(
    tabsetPanel(
      tabPanel("Time Series Plot", plotOutput("timeplot")),
      tabPanel("Box Plot", plotOutput("boxplot")),
      tabPanel("Scatter Plot", plotOutput("scatterplot"), height="auto")
      
        
    )
  )
))
