library(shiny)
library(fOptions)
library(rJava)
library(shinythemes)
library(microbenchmark)
library(data.table)
library(plotly)
library(Rcpp)
source("cpp/CRRcpp.R")


.jinit()

.jaddClassPath('java/CRR.jar')
crr <-.jnew('CRR')




# Define UI for application that draws a histogram
ui <- fluidPage(
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

# Define server logic required to draw a histogram
server <- function(input, output,session) {
    
  temp.data <- data.table()
    
  session$onSessionEnded(function(){
    temp.data <<- data.table()
  })
  
   observeEvent(input$calculate,{
     
    rs <- c()
    
    S <- as.double(input$stock_price_input)
    Time <- as.double(input$time_input)
    r <- as.double(input$rf_input)
    cost_of_carry <- as.double((input$rf_input - input$dividend_input))
    div_yield <- as.double((input$dividend_input))
    vola <- as.double(input$vola_input)
    X <- as.double(input$strike_input)
    
    type <- paste0( input$option_type_input , input$option_style_input )
     
    if(input$method_input == 1){
      
      mbm <-microbenchmark(
        R =  CRRBinomialTreeOption(TypeFlag = type, S=S,X= X,
                                   Time= Time ,r= r, b= cost_of_carry, sigma = vola , input$bt_length_input )
        ,times = 10, unit = "ms")
      

      for (i in 1:(input$bt_length_input)) {
        
        rs[i]<-  CRRBinomialTreeOption(TypeFlag = type, S=S,X= X,
                                       Time= Time ,r= r, b= cost_of_carry, sigma = vola , i)@price
      }

      
    } else if(input$method_input == 2) {

      mbm <-microbenchmark(
        Java = crr$crr(type,S , X, Time , r ,div_yield , vola , input$bt_length_input ) 
          ,times = 10, unit = "ms")
      
      for (i in 1:(input$bt_length_input)){
        
        rs[i] <- crr$crr(type,S , X, Time , r ,div_yield , vola ,as.integer(i))
        
      }

    } else {
      
      mbm <-microbenchmark(
        'C++' = CRRcpp(type, S , X, Time , r ,div_yield , vola , input$bt_length_input ) 
        ,times = 10, unit = "ms" )
      
      for (i in 1:(input$bt_length_input)){
        
        rs[i] <- CRRcpp(type,S , X, Time , r ,div_yield , vola ,as.integer(i))
        
      }
      
    }
    
    
    mbm.df <-summary(mbm)
    mbm.df$`Tree Length` <- input$bt_length_input
    colnames(mbm.df)[1] <- "Language"
    mbm.df <- mbm.df[,-which(colnames(mbm.df) %in% c("lq","uq"))] 
    mbm.df$`Option Type` <- toupper(type)
    temp.data <<- rbindlist(list(temp.data ,mbm.df ))
    
    output$plot <- renderPlotly({
      
        p<-plot_ly(source = "source") %>% 
          add_lines( x = 1:(length(rs)) , y = rs, mode = "lines", line = list(width = 1) , name = "CRR Prices")%>%
          layout(legend = list(orientation = 'h'))
        
        if( tolower(type) == "ce"| tolower(type) == "pe"){
          
          analytical_price <- GBSOption(TypeFlag = substr(type , start = 1, stop = 1)  , S=S,X= X,
                                Time= Time ,r= r, b= cost_of_carry, sigma = vola)@price
          
          p <- p %>%  add_segments(y = analytical_price, yend =analytical_price , 
                                   x = 1 , xend = (length(rs)), name = "Analytical Price")
          
        }
          
          p

    })
    
    output$benchmark_table <- renderDataTable(options = list(filter="none",
                                                             searching = FALSE,
                                                             paging = FALSE),{temp.data})
   })

}

# Run the application 
shinyApp(ui = ui, server = server)

