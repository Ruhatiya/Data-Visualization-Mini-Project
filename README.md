# DV_Mini_Project

# Shiny Dashboard Stock Market Dashboard

This Shiny app creates a dashboard that allows the user to select a stock symbol, the start and end dates, and the number of days for the moving average and RSI calculation. It generates a chart of the stock's price and technical indicators (moving averages, RSI, and MACD). The dashboard also includes a comparison tab that displays a pie chart and a bar plot comparing the chosen stocks.

# Prerequisites

This app requires the following libraries to be installed:

1. shiny
2. shinydashboard
3. quantmod
4. ggplot2


# How to run the app

1. Install the required libraries.
2. Load the Shiny library by running library(shiny).
3. Run the app using the shinyApp() function.

# How to use the app

1. Select a stock symbol from the dropdown menu.
2. Select the start and end dates for the stock data.
3. Use the slider to select the number of days for the moving average.
4. Use the dropdown menu to select the number of days for the RSI calculation.
5. The app will generate a chart of the stock's price and technical indicators.
6. Switch to the "Comparisons" tab to compare the chosen stocks.
7. Dashboard has Help tab in case you do not understand any term 

# Screenshots of the app

![img1](https://drive.google.com/file/d/1QgeN4JZGuoEG8VgKuROtflzCCKjYMOV2/view?usp=share_link "Tab 1")
![img2](https://drive.google.com/file/d/16S91atH4PCWiDV4vjhCsAlAh0bQSKk6N/view?usp=share_link "Tab 2")
![img3](https://drive.google.com/file/d/1oAnU4llyK4w94j0GGcGekKXqrkF_qF0K/view?usp=share_link "Tab 3")


# File structure

main.R: the Shiny app


# Acknowledgements

This app was created using the shinydashboard package for Shiny by RStudio. It also uses the quantmod package for retrieving and manipulating financial data and the ggplot2 package for generating charts.
# Data-Visualization-Mini-Project
