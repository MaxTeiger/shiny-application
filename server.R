

trains_df <- read.csv("full_trains.csv", stringsAsFactors = FALSE)
airports <- read.csv("airports.csv", stringsAsFactors = FALSE, nrows = 1000)
flights <- read.csv("flights.csv", stringsAsFactors = FALSE)
airlines <- read.csv("airlines.csv", stringsAsFactors = FALSE, nrows = 1000)

flights2 <- NULL
flights$date <- as.Date(with(flights, paste(YEAR, MONTH, DAY,sep="-")), "%Y-%m-%d")
tablef = select(.data = flights, origin = "ORIGIN_AIRPORT", dest = "DESTINATION_AIRPORT")
aeropuerto = select(.data = airports, airport = "IATA_CODE", lat = "LATITUDE", lon = "LONGITUDE")
airlines = select(.data = airlines, code = "IATA_CODE", airline = "AIRLINE")
flights_latlon <- tablef %>% inner_join(select(.data = aeropuerto, origin = airport, origin_lat = lat, origin_lon = lon), 
                                   by = "origin") %>% 
  inner_join(select(.data = aeropuerto, dest = airport, dest_lat = lat, dest_lon = lon), 
             by = "dest")
flights$AIRLINES <- airlines$airline[match(flights$AIRLINE, airlines$code)]
flights$city <- airports$CITY[match(flights$DESTINATION_AIRPORT, airports$IATA_CODE)]

flightss <- flights
flightss$ARRIVAL_TIME <- format(strptime(sprintf('%04d', flightss$ARRIVAL_TIME), format='%H%M'), '%H:%M')
flightss$DEPARTURE_TIME <- format(strptime(sprintf('%04d', flightss$DEPARTURE_TIME), format='%H%M'), '%H:%M')
flightss$ARRIVAL_TIME <- as.POSIXlt(as.character(flightss$ARRIVAL_TIME), format = "%H:%M")
flightss$DEPARTURE_TIME <- as.POSIXlt(as.character(flightss$DEPARTURE_TIME), format = "%H:%M")

flights_latlon <- head(flights_latlon,100)



server <- function(input, output) {
  
  output$annee <- renderUI({
    selectInput("choix_annee", "Année :",
                c("ALL",sort(unique(trains_df[,"year"]))),
    )
  })
  
  output$gare <- renderUI({
    selectInput("choix_gare", "Gare :",
                c("ALL",sort(unique(trains_df[,"departure_station"]))),
    )
  })
  
 
  
  output$nombre_train <- renderValueBox({
    data <- sum(trains_data()$total_num_trips)-sum(trains_data()[!is.na(trains_data()$num_of_canceled_trains),]$num_of_canceled_trains)
    if(data == "NaN")
      data = "Unknown"
    else
      data = round(data)
    data %>%
      valueBox(subtitle = "Nombre de train", icon("train"),color = "red")
  })
  
  output$nombre_retard_depart <- renderValueBox({
    data <- sum(trains_data()[!is.na(trains_data()$num_late_at_departure),]$num_late_at_departure)
    if(data == "NaN")
      data = "Unknown"
    else
      data = round(data)
    data %>%
      valueBox(subtitle = "Nombre de train retardés au départ", icon("clock"),color = "yellow")
  })
  
  output$nombre_retard_arrivee <- renderValueBox({
    data <- sum(trains_data()[!is.na(trains_data()$num_arriving_late),]$num_arriving_late)
    if(data == "NaN")
      data = "Unknown"
    else
      data = round(data)
    data %>%
      valueBox(subtitle = "Nombre de train retardés à l'arrivée", icon("clock"),color = "aqua")
  })
  
  output$moyen_retard_arrivee <- renderValueBox({
    data <- mean(trains_data()[!is.na(trains_data()$num_arriving_late),]$num_arriving_late)
    if(data == "NaN")
      data = "Unknown"
    else
      data = round(data)
    data %>%
      valueBox(subtitle = "Nombre de train moyen retardé à l'arrivée", icon("clock"),color = "yellow")
  })
  
  output$moyen_retard_depart <- renderValueBox({
    data <- mean(trains_data()[!is.na(trains_data()$num_late_at_departure),]$num_late_at_departure)
    if(data == "NaN")
      data = "Unknown"
    else
      data = round(data)
    data %>%
      valueBox(subtitle = "Nombre de train moyen retardé au départ", icon("clock"),color = "red")
  })
  
  output$moyen_retard_tout_train_depart <- renderValueBox({
    data <- mean(trains_data()[!is.na(trains_data()$avg_delay_all_departing),]$avg_delay_all_departing)
    if(data == "NaN")
      data = "Unknown"
    else
      data = paste(round(data), "min")
    data %>%
      valueBox(subtitle = "Retard moyen pour tous les trains au départ", icon("clock"),color = "aqua")
    
  })
  
  output$moyen_retard_tout_train_arrivee <- renderValueBox({
    data <- mean(trains_data()[!is.na(trains_data()$avg_delay_all_arriving),]$avg_delay_all_arriving)
    if(data == "NaN")
      data = "Unknown"
    else
      data = paste(round(data), "min")
    data %>%
      valueBox(subtitle = "Retard moyen pour tous les trains à l'arrivée", icon("clock"),color = "red")
  })
  
  output$temps_moyen_retard_depart <- renderValueBox({
    data <- mean(trains_data()[!is.na(trains_data()$avg_delay_late_at_departure),]$avg_delay_late_at_departure)
    if(data == "NaN")
      data = "Unknown"
    else
      data = paste(round(data), "min")
    data %>%
      valueBox(subtitle = "Temps moyen des trains en retard au départ", icon("clock"),color = "yellow")
  })
  
  output$temps_moyen_retard_arrivee <- renderValueBox({
    data <- mean(trains_data()[!is.na(trains_data()$avg_delay_late_on_arrival),]$avg_delay_late_on_arrival)
    if(data == "NaN")
      data = "Unknown"
    else
      data = paste(round(data), "min")
    data %>%
      valueBox(subtitle = "Temps moyen des trains en retard à l'arrivée", icon("clock"),color = "aqua")
  })
  
  output$nb_total_train_annul <- renderValueBox({
    data <- sum(trains_data()[!is.na(trains_data()$num_of_canceled_trains),]$num_of_canceled_trains)
    if(data == "NaN")
      data = "Unknown"
    else
      data = round(data)
    data %>%
      valueBox(subtitle = "Nombre de train annulés", icon("window-close"),color = "red")
  })
  
  output$pourcentage_trains_annul <- renderValueBox({
    data <- sum(trains_data()[!is.na(trains_data()$num_of_canceled_trains),]$num_of_canceled_trains)*100
    data <- data / sum(trains_data()$total_num_trips)
    if(data == "NaN")
      data = "Unknown"
    else
      data = paste(round(data,3),"%")
    data %>%
      valueBox(subtitle = "Proportion des trains annulés", icon("percentage"),color = "yellow")
  })
  
  output$causes_retard<- renderPlot({
    ext = mean(trains_data()[!is.na(trains_data()$delay_cause_external_cause),]$delay_cause_external_cause)
    rail = mean(trains_data()[!is.na(trains_data()$delay_cause_rail_infrastructure),]$delay_cause_rail_infrastructure)
    traffic = mean(trains_data()[!is.na(trains_data()$delay_cause_traffic_management),]$delay_cause_traffic_management)
    rolling = mean(trains_data()[!is.na(trains_data()$delay_cause_rolling_stock),]$delay_cause_rolling_stock)
    station = mean(trains_data()[!is.na(trains_data()$delay_cause_station_management),]$delay_cause_station_management)
    travelers = mean(trains_data()[!is.na(trains_data()$delay_cause_travelers),]$delay_cause_travelers)
    myPalette <- brewer.pal(5, "Set2") 
    
    slices <- c(ext, rail, traffic, rolling, station, travelers)
    lbls <- c("External", "Rail Infrastructure", "Traffic management", "Rolling stock", "Station management", "Travelers")    
    camambert <- data.frame(value=slices, causes=lbls, row.names=NULL)
    
    colnames(camambert) <-c("value","causes")
    blank_theme <- theme_minimal()+
      theme(
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.border = element_blank(),
        panel.grid=element_blank(),
        panel.background = element_rect(fill = "transparent",
                                        colour = "transparent"),
        axis.ticks = element_blank(),
        plot.title=element_text(size=14, face="bold"),
        plot.background = element_rect(fill = "transparent",colour = "transparent")
      )
    
    
    
    ggplot(data = camambert, aes(x=0, y=value))+
      geom_bar(width = 1, stat = "identity", aes(fill=causes)) + 
      coord_polar(theta = "y") +
      scale_fill_brewer("Causes") + blank_theme +
      theme(axis.text.x=element_blank())+
      geom_label(aes(label = paste(round(value,2),"%"),group = causes),position = position_stack(vjust = 0.5) , show.legend = FALSE)
    
  }, bg="transparent")

  output$gare_destination <- renderUI({
    selectInput("choix_gare_dest", "Gare de destination :",
                c("ALL",sort(unique(trains_df[,"arrival_station"]))),
    )
  })
  trains_data2 <- reactive({
    
    if(input$choix_annee=="ALL" & input$choix_gare=="ALL" & input$choix_gare_dest=="ALL"){
      trains_df <- trains_df
    }
    else if(input$choix_annee=="ALL"& input$choix_gare_dest=="ALL"){
      trains_df <- subset(trains_df,  departure_station == input$choix_gare )
    }
    else if(input$choix_gare=="ALL" & input$choix_gare_dest=="ALL"){
      trains_df <- subset(trains_df,  year == input$choix_annee )
    }
    else if(input$choix_gare=="ALL" & input$choix_annee=="ALL"){
      trains_df <- subset(trains_df,  arrival_station == input$choix_gare_dest)
    }
    else if(input$choix_gare=="ALL" ){
      trains_df <- subset(trains_df,  arrival_station == input$choix_gare_dest & year == input$choix_annee)
    }
    else if(input$choix_annee=="ALL" ){
      trains_df <- subset(trains_df,  arrival_station == input$choix_gare_dest & departure_station == input$choix_gare)
    }
    else if(input$choix_gare_dest=="ALL" ){
      trains_df <- subset(trains_df,  year == input$choix_annee & departure_station == input$choix_gare)
    }
    else{
      trains_df <- subset(trains_df,  year == input$choix_annee & departure_station == input$choix_gare & arrival_station == input$choix_gare_dest)
    }
    
  })
  
  output$nb_voyage <- renderValueBox({
    data <- sum(trains_data2()$total_num_trips)-sum(trains_data2()[!is.na(trains_data2()$num_of_canceled_trains),]$num_of_canceled_trains)
    if(data == "NaN")
      data = "Unknown"
    else
      data = round(data)
    data %>%
      valueBox(subtitle = paste("Nombre de train en direction de ",input$choix_gare_dest), icon("train"),color = "red")
  })
  
  
  trains_data <- reactive({
    if(input$choix_annee=="ALL" & input$choix_gare=="ALL"){
      trains_df <- trains_df
    }
    else if(input$choix_annee=="ALL"){
      trains_df <- subset(trains_df,  departure_station == input$choix_gare )
    }
    else if(input$choix_gare=="ALL"){
      trains_df <- subset(trains_df,  year == input$choix_annee )
    }
    else{
      trains_df <- subset(trains_df,  year == input$choix_annee & departure_station == input$choix_gare)
    }
    
    
  })

  
  
  output$mymap <- renderLeaflet({
    m <- leaflet() %>%
      addTiles() %>%  # Add default OpenStreetMap map tiles
      addCircleMarkers(lng=airports$LONGITUDE, lat=airports$LATITUDE, radius = 1, label = airports$AIRPORT) %>%
      addPolylines(weight = 0.3, opacity = 0.5, color = "#820a0a", lat=c(flights_latlon$origin_lat,flights_latlon$dest_lat), 
                   lng=c(flights_latlon$origin_lon, flights_latlon$dest_lon))
  })
  
  output$choix_aggregation <- renderUI({
    
    selectInput("choix_agg", "Aggréger en premier avec :",
                c("Compagnie aerienne"="input$choix_airline,AIRLINES","Aeroport d'origine"="input$choix_aeroport,ORIGIN_AIRPORT"),
    )
    
  })
  output$Compagnie_aerienne <- renderUI({
    choix<-strsplit(input$choix_agg, "," )
    if(choix[[1]][2]=="ORIGIN_AIRPORT"){
      selectInput("choix_airline", "Compagnie aerienne :",
                  c("ALL",sort(unique(subset(flights,  ORIGIN_AIRPORT == input$choix_aeroport )[,"AIRLINES"]))),
      )}else{
        selectInput("choix_airline", paste("Compagnie aerienne :"),
                    c("ALL",sort(unique(flights[,"AIRLINES"]))),
        )
      }
    
    
  })
  
  output$aeroport_origine <- renderUI({
    choix<-strsplit(input$choix_agg, "," )
    if(choix[[1]][2]=="AIRLINES"){
      selectInput("choix_aeroport", "Aeroport d'origine :",
                  c("ALL",sort(unique(subset(flights,  AIRLINES == input$choix_airline  )[,"ORIGIN_AIRPORT"]))),
      )}else{
        selectInput("choix_aeroport", "Aeroport d'origine :",
                    c("ALL",sort(unique(flights[,"ORIGIN_AIRPORT"]))),
        )
      }
    
    
  })
  
  avion_agg <- reactive({
    
    if(is.null(input$choix_airline) | is.null(input$choix_aeroport)){
      flights <- flights
    }else
      if(input$choix_airline=="ALL" & input$choix_aeroport=="ALL"){
        flights <- flights
      }
    else if(input$choix_airline=="ALL"){
      flights <- subset(flights,  ORIGIN_AIRPORT == input$choix_aeroport )
    }
    else if(input$choix_aeroport=="ALL"){
      flights <- subset(flights,  AIRLINES == input$choix_airline )
    }
    else{
      flights <- subset(flights,  ORIGIN_AIRPORT == input$choix_aeroport & AIRLINES == input$choix_airline)
    }
    
    
  })
  
  output$choix_aggregation2 <- renderUI({
    
    selectInput("choix_agg2", "Aggréger en premier avec :",
                c("Compagnie aerienne"="input$choix_airline2,AIRLINES","Aeroport d'origine"="input$choix_aeroport2,ORIGIN_AIRPORT"),
    )
    
  })
  output$Compagnie_aerienne2 <- renderUI({
    choix<-strsplit(input$choix_agg2, "," )
    if(choix[[1]][2]=="ORIGIN_AIRPORT"){
      selectInput("choix_airline2", "Compagnie aerienne :",
                  c("ALL",sort(unique(subset(flights,  ORIGIN_AIRPORT == input$choix_aeroport2 )[,"AIRLINES"]))),
      )}else{
        selectInput("choix_airline2", paste("Compagnie aerienne :"),
                    c("ALL",sort(unique(flights[,"AIRLINES"]))),
        )
      }
    
    
  })
  
  output$aeroport_origine2 <- renderUI({
    choix<-strsplit(input$choix_agg2, "," )
    if(choix[[1]][2]=="AIRLINES"){
      selectInput("choix_aeroport2", "Aeroport d'origine :",
                  c("ALL",sort(unique(subset(flights,  AIRLINES == input$choix_airline2  )[,"ORIGIN_AIRPORT"]))),
      )}else{
        selectInput("choix_aeroport2", "Aeroport d'origine :",
                    c("ALL",sort(unique(flights[,"ORIGIN_AIRPORT"]))),
        )
      }
    
    
  })
  
  output$aeroport_destination <- renderUI({
    if(input$choix_aeroport2=="ALL" | input$choix_airline2=="ALL"){
        selectInput("choix_destination", "Aeroport de destination :",
                    c("ALL",sort(unique(flights[,"DESTINATION_AIRPORT"]))),
        )}
    if(input$choix_airline2=="ALL" ){
      selectInput("choix_destination", "Aeroport de destination :",
                  c("ALL",sort(unique(subset(flights,  ORIGIN_AIRPORT == input$choix_aeroport2)[,"DESTINATION_AIRPORT"]))),
      )}
    if(input$choix_aeroport2=="ALL" ){
      selectInput("choix_destination", "Aeroport de destination :",
                  c("ALL",sort(unique(subset(flights,   AIRLINES == input$choix_airline2)[,"DESTINATION_AIRPORT"]))),
      )}else{
          selectInput("choix_destination", "Aeroport de destination :",
                      c("ALL",sort(unique(subset(flights,  ORIGIN_AIRPORT == input$choix_aeroport2 & AIRLINES == input$choix_airline2)[,"DESTINATION_AIRPORT"]))),
          )
        }
  })
  
  avion_agg2 <- reactive({
    flights <- flights
    
    if(is.null(length(input$choix_airline2)) | is.null(length(input$choix_aeroport2)) | is.null(length(input$choix_destination))){
      flights <- flights
    }else
    if(input$choix_airline2=="ALL" & input$choix_aeroport2=="ALL" & input$choix_destination=="ALL"){
      flights <- flights
    }
    else if(input$choix_airline2=="ALL" & input$choix_aeroport2=="ALL"){
      flights <- subset(flights,  DESTINATION_AIRPORT == input$choix_destination )
    }
    else if(input$choix_aeroport2=="ALL" & input$choix_destination=="ALL"){
      flights <- subset(flights,  AIRLINES == input$choix_airline2 )
    }
    else if(input$choix_airline2=="ALL" & input$choix_destination=="ALL"){
      flights <- subset(flights,  ORIGIN_AIRPORT == input$choix_aeroport2 )
    }
    else if(input$choix_destination=="ALL"){
      flights <- subset(flights,  ORIGIN_AIRPORT == input$choix_aeroport2 & AIRLINES == input$choix_airline2)
    }
    else if(input$choix_airline2=="ALL"){
      flights <- subset(flights,  ORIGIN_AIRPORT == input$choix_aeroport2 & DESTINATION_AIRPORT == input$choix_destination)
    }
    else if(input$choix_aeroport2=="ALL"){
      flights <- subset(flights,  AIRLINES == input$choix_airline2 & DESTINATION_AIRPORT == input$choix_destination)
    }
    else{
      flights <- subset(flights,  AIRLINES == input$choix_airline2 & DESTINATION_AIRPORT == input$choix_destination & ORIGIN_AIRPORT == input$choix_aeroport2)
    }
    
  })

  output$nb_voyage_avion <- renderValueBox({
   
    nrow(avion_agg2()) %>%
      valueBox(paste("Nombre de vol en direction de ",input$choix_destination), icon("plane"),color="green")
  })
  
  output$nb_vol <- renderValueBox({
    nrow(avion_agg()) %>%
      valueBox("Nombre de vol total", icon("plane"),color = "yellow")
  })
  

  
  output$distance_total <- renderValueBox({
    data <- sum(avion_agg()$DISTANCE)
    if(data == "NaN")
      data = "Unknown"
    else
      data = round(data)
    paste(data,"km") %>%
      valueBox(subtitle = "Distance total", icon("tachometer-alt"),color = "red")
  })
  
  avg_duration <- reactive({
    data <- avion_agg()$ARRIVAL_TIME-avion_agg()$DEPARTURE_TIME
    data <- mean(as.numeric(data[!is.na(data)]))
    if(data == "NaN")
      data = "Unknown"
    else
      data = round(data)
  })
  
  output$duree_moyen_vol <- renderValueBox({
    paste(avg_duration(),"min") %>%
      valueBox(subtitle = "Durée moyenne d'un vol", icon("hourglass-half"),color="green")
  })
  
  output$distance_moyen_vol <- renderValueBox({
    data <- mean(avion_agg()$DISTANCE[!is.na(avion_agg()$DISTANCE)])
    if(data == "NaN")
      data = "Unknown"
    else
      data = round(data)
    paste(data,"km") %>%
      valueBox(subtitle = "Distance moyenne d'un vol",icon("tachometer-alt"))
  })
  
  output$retard_moyen_depart <- renderValueBox({
    data <- mean(avion_agg()$DEPARTURE_DELAY[!is.na(avion_agg()$DEPARTURE_DELAY)])
    if(data == "NaN")
      data = "Unknown"
    else
      data = round(data)
    paste(data,"min") %>%
      valueBox(subtitle = "Retard moyen au départ", icon("clock"),color="green")
  })
  
  output$retard_moyen_arrivee <- renderValueBox({
    data <- mean(avion_agg()$ARRIVAL_DELAY[!is.na(avion_agg()$ARRIVAL_DELAY)])
    if(data == "NaN")
      data = "Unknown"
    else
      data = round(data)
    paste(data,"min") %>%
      valueBox(subtitle = "Retard moyen à l'arrivée", icon("clock"),color="red")
  })
  
  output$nb_retard <- renderValueBox({
    data <- avion_agg()[!is.na(avion_agg()$DEPARTURE_DELAY),]
    data <- data[!is.na(data$ARRIVAL_DELAY),]
    data <- sum(data$DEPARTURE_DELAY > 0 | data$ARRIVAL_DELAY > 0)
    data %>%
      valueBox(subtitle = "Nombre total d'avion retardés", icon("clock"),color="yellow")
  })
  
}

