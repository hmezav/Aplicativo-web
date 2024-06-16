## carpeta de trabajo  

## paquetes necesarios
library(shiny)
library(shinydashboard)
library(tidyverse)
library(dashboardthemes)
library(htmlwidgets)
library(DT)
library(reactablefmtr)
library(here)
library(markdown)
library(ngram)
library(easyPubMed)
library(pubmed.mineR)
library(wordcloud)
library(shinyBS)
library(rgl)
library(lsa)
### archivos necesarios

### Configurar encabezado del dashboard

dbHeader <- dashboardHeader(
  
  
  title =  "Autoinmune Explorer",
  titleWidth = "320px",
  
  tags$li(a(href = 'https://www.uoc.edu/es',
            tags$img(src = 'https://files.ingebook.com/ib/img/ingebook/ESP/logos_biblioteca/uoc.png',
                     title = "Pagina Universidad",
                     height = "50px"),
            style = "padding-top:10px; padding-bottom:10px;"),
          class = "dropdown"),
  
  tags$li(a(href = 'https://pubmed.ncbi.nlm.nih.gov/',
            tags$img(src = 'https://th.bing.com/th/id/R.9868d2900ed5e76161648d9423e7afad?rik=hdgjjI6EO39fEQ&pid=ImgRaw&r=0',
                     title = "Pagina viviendas",
                     height = "50px"),
            style = "padding-top:10px; padding-bottom:10px;"),
          class = "dropdown"),
  
   tags$li(a(href = 'https://shiny.posit.co/',
            tags$img(src = 'https://stevenmortimer.com/blog/tips-for-making-professional-shiny-apps-with-r/shiny-hex.png',
                     title = "Pagina viviendas",
                     height = "50px"),
            style = "padding-top:10px; padding-bottom:10px;"),
          class = "dropdown")
)


## contenido de sidebar 

dbsider <- dashboardSidebar(
  sidebarMenu(id = "partes",
              
              menuItem("Clasificación de las enfermedades",
                       tabName = "intro"),
              
              menuItem("Enfermedades autoinmunitarias", 
                       tabName = "tipos",
                       
                       menuSubItem("Autoinmunitarias sistémicas",
                                   tabName = "sistémicas"),
                       
                       menuSubItem("Autoinmunitarias órgano-específicas",
                                   tabName = "específicas")),
                       
              
              menuItem("Análisis de las publicaciones",
                       tabName = "analisis")
  ), width = 320
  
)





### cuerpo del dashboard

## añadir carpeta de html para archivos 

dbody <- dashboardBody(
  
  ## incluir css
  includeCSS("estilo.css"),
  
  tabItems(
    
    ## introducción
    tabItem(
      tabName = "intro",
      fluidPage(
      fluidRow(
      mainPanel(uiOutput("tabla1"), width = 12)
    ))
  ), 
  
  tabItem(tabName = "sistémicas",
          
          
          source("Bodys/sistematicas body.R")[1]
          
          ), 
  
  tabItem(tabName =  "específicas", 
          
          source("Bodys/organoespecificas body.R")[1]),
  
  
  tabItem(tabName = "analisis",
          
          source("Bodys/Relaciones body.R")[1]
          )
  
  
))


## construcción de la ui
ui <- dashboardPage(
  dbHeader,
  dbsider,
  dbody)




server <- function(input, output){ 
  
  output$tabla1 <- renderUI(tags$iframe(style="height:900px; width:100%;",
                                        src="CLASIFICACIÓN DE LAS ENFERMEDADES AUTOINMUNITARIAS.pdf"))
  
  source("Servers/sistematicas server.R", local = T)
  source("Servers/organoespecíficas server.R", local = T)
  source("Servers/relaciones server.R", local = T)

} 


shinyApp(ui, server)