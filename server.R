#################################################################################
#### Author: Fedor Kolyadin
#### Date: April, 2015
#### Description: An R implementation of ARIMA with visualization in Shiny 
#################################################################################

library(RPostgreSQL)
library(DBI)
library(xts)
library(forecast)
library(lubridate)
library(reshape2)
library(xlsx)
library(rCharts)

drv = dbDriver("PostgreSQL") # Driver to connect to PostgreSQL
# hashed1 <- scrypt::hashPassword("xxx")
# scrypt::verifyPassword(hashed1, "x")
con = dbConnect(drv, user = "xxx", password = "xxx", dbname = "QTRACK", host = "xxx", port = 5432) # Connection variable to build the connection to Pgres
gdp <- dbGetQuery (con, "select date, gdp_nat_log from macro ")
hpi <- dbGetQuery (con, "select date, hpi_nat_log from macro ")
unrate <- dbGetQuery (con, "select date, unrate_nat_log from macro ")

# mydata$Date <- as.Date(as.character(mydata$Date, format = "%Y-%m-%d"))
# gdp <- unique(mydata[c(1,2)])
# hpi <- unique(mydata[c(1,3)])
# unrate <- unique(mydata[c(1,4)])

gdpXts <- xts(gdp$gdp_nat, gdp$date)
gdpXts <- to.yearly(gdpXts)
gdpSeries <- as.ts(gdpXts[,4], start = c(1976))

hpiXts <- xts(hpi$hpi_nat, hpi$date)
hpiXts <- to.yearly(hpiXts)
hpiSeries <- as.ts(hpiXts[,4], start = c(1976))

unrateXts <- xts(unrate$unrate_nat, unrate$date)
unrateXts <- to.yearly(unrateXts)
unrateSeries <- as.ts(unrateXts[,4], start = c(1976))

data_sets <- c("GDP", "HPI", "UNRATE" )

fit_gdp <- auto.arima(gdpSeries)
fcast_gdp <- forecast(fit_gdp)

fit_hpi <- auto.arima(hpiSeries)
fcast_hpi <- forecast(fit_hpi)

fit_unrate <- auto.arima(unrateSeries)
fcast_unrate <- forecast(fit_unrate)

## The following code takes the input from the UI.r to display the prediction
shinyServer(function(input, output) {
    
    datasetInput <- reactive({
      switch(input$dataset,
             "GDP" = gdpSeries,
             "HPI" = hpiSeries,
             "UNRATE" = unrateSeries)
    })
    
    output$plot_gdp <- renderPlot({ plot(fcast_gdp, ylab='GDP (log)',xlab='Year',
                                         pch=20, lty=1,type='o', col = 'orangered')})    
    output$plot_hpi <- renderPlot({ plot(fcast_hpi, ylab='HPI (log)',xlab='Year',
                                         pch=20, lty=1,type='o', col = 'gold')})
    output$plot_unrate <- renderPlot({ plot(fcast_unrate, ylab='UNRATE (log)',xlab='Year',
                                        pch=20, lty=1,type='o', col = 'springgreen')})
    
    output$Fcast_gdp <- renderDataTable({Fcast_gdp <- as.data.frame(fcast_gdp)
                                      Fcast_gdp})
    
    output$Fcast_hpi <- renderDataTable({Fcast_hpi <- as.data.frame(fcast_hpi)
                                     Fcast_hpi})
    
    output$Fcast_unrate <- renderDataTable({Fcast_unrate <- as.data.frame(fcast_unrate)
                                     Fcast_unrate})
})

dbDisconnect(con)
