library(shiny)
library(shinydashboard)
library(quantmod)
library(ggplot2)

symbol <- c("AAPL", "GOOG", "TSLA", "FB", "AMZN")
shares <- c(100, 50, 200, 75, 150)
stock_data <- data.frame("Stock Symbols" = symbol, "No of shares" = shares)

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Portfolio", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Comparisons", icon = icon("th"), tabName = "widgets",
               badgeLabel = "new", badgeColor = "green"),
      menuItem("Help", tabName = "help", icon = icon("?"))
    ),
    
    selectInput(inputId = "symbol",
                label = "Select a stock symbol:",
                choices = c("AAPL", "GOOG", "TSLA", "FB", "AMZN"),
                selected = "AAPL"),
    dateInput(inputId = "start_date",
              label = "Start date:",
              value = as.Date("2010-01-01")),
    dateInput(inputId = "end_date",
              label = "End date:",
              value = Sys.Date()),
    sliderInput(inputId = "ma_days",
                label = "Select number of days for moving average:",
                min = 5, max = 100, value = 20),
    selectInput(inputId = "rsi_days",
                label = "Select number of days for RSI calculation:",
                choices = c(14, 21, 28),
                selected = 14)
    
    
  ),
  
  
  dashboardBody(
    
    tabItems(
      tabItem(
        tabName = "dashboard",
        h2("Portfolio tab content"),
        fluidRow(
          
          valueBoxOutput("last_price_box"),
          valueBoxOutput("progressBox"),
          valueBoxOutput("approvalBox"),
          
          box(
            title = "Stock Price Chart",
            plotOutput(outputId = "stock_price_chart", height = "342px")
          ),
          box(
            title = "Technical Indicators",
            tabsetPanel(
              type = "tabs",
              tabPanel("Moving Averages", plotOutput(outputId = "moving_averages_chart", height = "300px")),
              tabPanel("Relative Strength Index", plotOutput(outputId = "rsi_chart", height = "300px")),
              tabPanel("MACD", plotOutput(outputId = "macd_chart", height = "300px"))
            )
          ),
        ),
        
      ),
      
      tabItem(
        tabName = "widgets",
        h2("Comparisons tab content"),
        fluidRow(
          box(
            title = "Pie Chart", 
            plotOutput("pie_chart", height="250px")
          ),
          box(
            title = "Bar Plot",
            plotOutput("bar_plot", height="250px")
          )
        ),
        
        fluidRow(
          infoBox(
            checkboxGroupInput("stocks", 
                               label = "Choose stocks to display:",
                               choices = c("AAPL", "GOOG", "TSLA", "AMZN"),
                               selected = c("AAPL", "GOOG", "TSLA", "AMZN"))
            
            )
        )
      ),
      tabItem(
        tabName = "help",
        verbatimTextOutput("textbox")
      )
    )
    
    
    
  )
  
  
  
)

# Define server
server <- function(input, output) {
  
  # Load stock data
  stock_data <- reactive({
    getSymbols(input$symbol, src = "yahoo", from = input$start_date, to = input$end_date, auto.assign = FALSE)
  })
  
  # Generate stock price chart
  output$stock_price_chart <- renderPlot({
    chartSeries(stock_data(), TA = NULL, theme = "white")
  })
  
  # Generate moving averages chart
  output$moving_averages_chart <- renderPlot({
    chartSeries(stock_data(), theme = "white")
    addSMA(n = input$ma_days, col = c("red", "blue", "green"))
  })
  
  # Generate RSI chart
  output$rsi_chart <- renderPlot({
    chartSeries(stock_data(), theme = "white")
    addRSI(n = input$rsi_days)
  })
  
  # Generate MACD chart
  output$macd_chart <- renderPlot({
    chartSeries(stock_data(), theme = "white")
    addMACD()
  })
  
  # Generate stock information table
  output$stock_info_table <- renderTable({
    data.frame(
      Symbol = input$symbol,
      "Last Price" = tail(Cl(stock_data()), n = 1),
      "52-Week High" = max(Hi(stock_data()[, input$symbol], na.rm = TRUE)),
      "52-Week Low" = min(Lo(stock_data()[, input$symbol], na.rm = TRUE)),
      "Volume" = tail(Vo(stock_data()), n = 1)
    )
  })
  
  
  # Generate pie chart for stock percentages
  output$pie_chart <- renderPlot({
    # Create the pie chart
    ggplot(stock_data, aes(x="", y=`No of shares`, fill=`Stock Symbols`)) +
      geom_bar(stat="identity", width=1, color="white") +
      coord_polar("y", start=0) +
      labs(title="Stock Distribution") +
      theme_void()
  })
  # Value boxes
  output$last_price_box <- renderValueBox({
    valueBox(
      paste0("$", round(tail(Cl(stock_data()), n = 1), 2)), "Last Price", icon = icon("line-chart"),
      color = "blue"
    )
  })
  
  output$progressBox <- renderValueBox({
    valueBox(
      paste0("$", max(stock_data())), "Highest Price", icon = icon("line-chart"),
      color = "purple"
    )
  })
  
  output$approvalBox <- renderValueBox({
    valueBox(
      paste0("$", round(mean(stock_data()), 2)), "Average Price", icon = icon("line-chart"),
      color = "yellow"
    )
  })
  
  # Create reactive dataset based on selected stocks
  stocks_data <- reactive({
    df <- tibble(
      Stock = c("AAPL", "GOOG", "TSLA", "AMZN"),
      `No of shares` = c(50, 75, 100, 25),
      Price = c(150, 1200, 750, 3200)
    )
    df %>% 
      filter(Stock %in% input$stocks) %>% 
      mutate(Total_Value = `No of shares` * Price) %>% 
      arrange(desc(Total_Value))
  })
  
  # Create pie chart
  output$pie_chart <- renderPlot({
    ggplot(data = stocks_data(), aes(x = "", y = Total_Value, fill = Stock)) +
      geom_bar(width = 1, stat = "identity") +
      coord_polar("y", start=0) +
      labs(x = NULL, y = NULL, fill = "Stock") +
      scale_fill_manual(values = c("AAPL" = "#FF0000", "GOOG" = "#00FF00", "TSLA" = "#0000FF", "AMZN" = "#FFA500"))
  })
  
  # Create bar plot
  output$bar_plot <- renderPlot({
    ggplot(data = stocks_data(), aes(x = reorder(Stock, Total_Value), y = Total_Value)) +
      geom_bar(stat = "identity", fill = "#0073C2FF") +
      labs(x = "Stock", y = "Total Value") +
      scale_y_continuous(labels = scales::dollar_format())
  })
  
  output$textbox <- renderText(
    "    
    Moving Average: A technical indicator used in stock trading to analyze
    a set of stock prices by creating a series of averages of different subsets
    of the full dataset. It's used to identify trends, support and resistance levels, 
    generate trading signals, measure volatility, and confirm other technical indicators.

    Relative Strength Index (RSI): A momentum oscillator that compares the magnitude of  
    recent gains to recent losses to determine overbought and oversold conditions of a security.  
    The RSI ranges from 0 to 100, with readings above 70 considered overbought and readings  
    below 30 considered oversold.
    
    MCAD, or Moving Average Convergence Divergence, is a technical indicator used in the 
    stock market to identify trend reversals and momentum shifts. It is calculated by subtracting
    the 26-day exponential moving average (EMA) from the 12-day EMA.The MCAD line is the result 
    of this calculation and is plotted on a chart. A nine-day EMA of the MCAD line is then 
    plotted as a signal line.

    "
    )
  
}

# Run the app
shinyApp(ui = ui, server = server)