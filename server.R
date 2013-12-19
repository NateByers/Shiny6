library(shiny)
if(!require(reshape2)){install.package("reshape2")}
library(reshape2)
if(!require(ggplot2)){install.packages("ggplot2")}
library(ggplot2)
if(!require(GGally)){install.packages("GGally")}
library(GGally)

# Load the ozone data, a dataframe labeled "data.o"
load("ozone.rda")

# load the weather data, a dataframe labeled "data.w"
load("weather.rda")

# Create a labels for the weather variables
labels <- c("Max Temp (degrees F)","Max Barometric Pressure(mb)", "Max Humidity(%)")
#"East 16th St. Monitor", "Harding St. Monitor", "Ft. Harrison Monitor", 

#--Define colours for raw & smoothed data:
col.raw <- "#377EB8"  #colset[2] } see note above
col.smooth <- "#E41A1C"  #colset[1] }
col.lm <- "grey20"

############## Define server logic ####################################################

shinyServer(function(input, output, session, clientData) {
  
  # Reactive function for selecting the data
  getLongData <- reactive({
    
    # get ozone data for user-selected monitor
    ozone.data <- subset(data.o, grepl(input$monitor, data.o[, "variable"]))
    
    # merge the ozone data from the monitor with the weather data
    merged.data <- rbind(ozone.data, data.w)
    
    # subset the data based on the years the user has selected
    merged.data <- subset(merged.data, date >= as.numeric(paste0(input$years[1], "0101")) &
                        date <= as.numeric(paste0(input$years[2], "1231")))
    
    # create the appropriate monitor label
    if(input$monitor=="harding") {monitor <- "Harding St. Monitor"} else
      if(input$monitor=="east.16th") {monitor <- "E. 16th St. Monitor"} else
        if(input$monitor=="ft.harrison") {monitor <- "Ft. Harrison Monitor"}
    
    # return a list of two data frames
    return(list(merged.data, ozone.data, monitor))
  })
  
  getWideData <- reactive({
    long.data <- getLongData()[[1]]
    
    wide.data <- dcast(long.data, date + j.day + month + year + warm.season ~ variable, value.var="value")
    
    # subset data down to the warm ("ozone") season
    wide.data <- wide.data[wide.data$warm.season==1,]
    
    return(wide.data)
  })
  
  
  
  # Time series plot
  output$timeplot <- renderPlot({
    
    
    # get the merged data from the reactive function (the first element of a list)
    data <- getLongData()[[1]]
    
    # get monitor label
    monitor <- getLongData()[[3]]
    
    # attach labels to the variables
    data[, "variable"] <- factor(data[, "variable"], labels = c(monitor, labels))
    
    # create basic ggplot
    plot <- ggplot(data, aes(x=as.Date(as.character(date), format="%Y%m%d"),
                               y=value, group=variable))
    
    # add facet_wrap to ggplot and print
    print(plot + facet_wrap( ~ variable, ncol=1, scale="free_y") + geom_line(color=col.raw) +
            stat_smooth(color=col.smooth) + xlab("Time") + 
            #ggtitle(paste0("Asthma ED Patients, ", names(main.title))) +
            theme(strip.text = element_text(size=12, face="bold"),
                  axis.title.x = element_text(face="bold", size=14),
                  axis.text.x  = element_text(size=12),
                  axis.title.y = element_text(face="bold", size=14),
                  strip.background = element_rect(fill="#ffe5cc"),
                  title = element_text(size=16, face="bold")))
  })
  
    
  output$boxplot <- renderPlot({
    
    # get the ozone data from the reactive function (the second element of a list)
    data <- getLongData()[[2]]
    
    # get the title for the graph from the name of the monitor variable
    title <- getLongData()[[3]]
    
    print(qplot(year, value, data=data, geom=c("boxplot", "jitter"), 
          fill=year, main=title,
          xlab="", ylab="Ozone Concentration (ppm)"))
  })
  
  # Scatter plot of selected monitor data
  output$scatterplot <- renderPlot({
    
    # get the merged data from the reactive function (the first element of a list)
    data <- getWideData()
    
    # rename the monitor column as ozone
    colnames(data)[6] <- "ozone"
    
    # get monitor label
    monitor <- getLongData()[[3]]
    
    # plot the paired variables
    print(ggpairs(na.omit(data[, c(4, 6:9)]), color='year', title=monitor))
    
  },  height=function() { session$clientData$output_scatterplot_width * 0.7 })
  
  
})



