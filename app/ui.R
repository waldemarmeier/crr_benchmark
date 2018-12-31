shinyUI(
  fluidPage(
    theme = shinytheme("flatly"),
    # Application title
    titlePanel("BSM Calculator"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
      sidebarPanel(
        class="left-form-cust" ,
        radioButtons("method_input", 
                     label = "Calculation Method", 
                     inline= T,
                     choices = list("R (fOptions)" = 1, "Java" = 2, "C++"=3),
                     selected = 1),
        radioButtons("option_type_input", 
                     label = "Option Type", 
                     inline= T,
                     choices = list(Call = "c", 
                                    Put = "p"),
                     selected = "c"),
        radioButtons("option_style_input", 
                     inline= T,
                     label = "Option Style",
                     choices = list(European = "e", 
                                    American = "a"),
                     selected = "e" ),
        numericInput("stock_price_input", label = "Underlying Price", value = 100),
        numericInput("strike_input", label = "Strike", value = 100),
        numericInput("time_input", label = "Expiration Time in years", value = 1),
        numericInput("rf_input", label = "Riskfree rate (as decimal number)", value = 0.05), 
        numericInput("dividend_input", label = "Dividend Yield", value = 0.00), 
        numericInput("vola_input", label = "Volatility", value = 0.1),
        numericInput("bt_length_input", label = "Length of Binomial Tree (it a long time for >1000)",
                     min = 1, 
                     max = 1000,step = 1,  
                     value = 10),
        actionButton("calculate", "Calculate")
        
        
        
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        plotlyOutput(outputId = "plot"),
        dataTableOutput(outputId = "benchmark_table")
      )
    )
  )
)