library(shinydashboard)
library(shiny)
library(dplyr)
library(tm)
library(stringr)
library(tidyr)
library(leaflet)
library(plotrix)
library(ggplot2)
library(wordcloud)

ui <- dashboardPage(skin = "red",
                    dashboardHeader(title = "Projet"),
                    dashboardSidebar(
                      sidebarMenu(
                        menuItem("Trains", tabName = "train", icon = icon("dashboard")
                        ),
                        menuItem("Avions", tabName = "avion", icon = icon("dashboard")
                        )
                      )
                    ),
                    dashboardBody(
                      tabItems(
                        tabItem(tabName = "train",
                                
                                fluidRow(
                                  box(
                                    uiOutput("annee", width = 6)
                                  ),
                                  box(
                                    
                                    uiOutput("gare", width = 6)
                                  ),
                                ),
                                tabsetPanel(
                                  tabPanel("Aggrégations", 
                                           fluidRow(
                                             valueBoxOutput("nombre_train", width = 6), 
                                             valueBoxOutput("nombre_retard_depart", width = 6),
                                             valueBoxOutput("nombre_retard_arrivee", width = 12),
                                           ),
                                           fluidRow(
                                             valueBoxOutput("moyen_retard_depart", width = 6),
                                             valueBoxOutput("moyen_retard_arrivee", width = 6),
                                             valueBoxOutput("moyen_retard_tout_train_depart", width = 12)
                                           ),
                                           fluidRow(
                                             valueBoxOutput("moyen_retard_tout_train_arrivee", width = 6),
                                             valueBoxOutput("temps_moyen_retard_depart", width = 6),
                                             valueBoxOutput("temps_moyen_retard_arrivee", width = 12),
                                           ),
                                           fluidRow(
                                             valueBoxOutput("nb_total_train_annul", width = 6),
                                             valueBoxOutput("pourcentage_trains_annul", width = 6),
                                           )
                                  ),
                                  tabPanel("Répartition des causes du retard",
                                           fluidRow(  
                                             box(
                                               plotOutput("causes_retard"),
                                               width = 8, status = "info", solidHeader = TRUE,
                                               title = "Répartition des causes du retard"
                                             )
                                           )
                                           
                                  ),
                                  tabPanel("Nombre de voyage",
                                           fluidRow(
                                             box(
                                               uiOutput("gare_destination", width = 6)
                                             ),
                                             fluidRow(
                                               valueBoxOutput("nb_voyage", width = 6)
                                             )
                                           )
                                  )
                                )
                        ),
                        
                        tabItem(tabName = "avion",
                                tabsetPanel(
                                  tabPanel("Map",
                                           fluidRow(
                                             leafletOutput("mymap"),br()
                                           )
                                           
                                  ),
                                  tabPanel("Aggrégations",
                                           fluidRow(
                                             box(
                                               uiOutput("choix_aggregation"), width = 12
                                             )
                                             
                                           ),
                                           fluidRow(box(
                                             uiOutput("Compagnie_aerienne", width = 6)
                                           ),
                                           box(
                                             uiOutput("aeroport_origine", width = 6)
                                           ))
                                           ,
                                           fluidRow(
                                             valueBoxOutput("distance_total", width = 6),
                                             valueBoxOutput("nb_vol", width = 6),
                                           ),
                                           fluidRow(
                                             valueBoxOutput("duree_moyen_vol", width = 4),
                                             valueBoxOutput("distance_moyen_vol", width = 4),
                                             valueBoxOutput("retard_moyen_depart", width = 4)
                                           ),
                                           fluidRow(
                                             valueBoxOutput("retard_moyen_arrivee", width = 6),
                                             valueBoxOutput("nb_retard", width = 6),
                                           )
                                  ),
                                  tabPanel("Nombre de voyage",
                                           
                                           fluidRow(
                                             box(
                                               uiOutput("choix_aggregation2"), width = 12
                                             )
                                             
                                           ),
                                           fluidRow(box(
                                             uiOutput("Compagnie_aerienne2", width = 6)
                                           ),
                                           box(
                                             uiOutput("aeroport_origine2", width = 6)
                                           )),
                                           fluidRow(
                                             
                                             box(
                                               uiOutput("aeroport_destination"),width = 12
                                             ),
                                             fluidRow(
                                               valueBoxOutput("nb_voyage_avion", width = 12),
                                               
                                             )
                                           )
                                          
                                           
                                  )
                                  
                                )
                        )
                
                        
                        
                      )
                    )
)