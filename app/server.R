shinyServer(function(input, output,session) {
  
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
  
})