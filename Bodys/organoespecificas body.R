

### body de enfermedades organo - especificas




fluidPage(
  
  ### mapa
  ### rmd sobre el sanitario de la vivienda
  fluidRow(
    titlePanel("Filtros para enfermedades autoinmunitarias órgano-específicas"),
    
    box(
      title = "Seleccione el tipo y la enfermedad a buscar",
      status = "primary", solidHeader = T, width = 12,
      height = 330,
      uiOutput("tipo_enfermedad2"),
      uiOutput("enfermedad2"),
      uiOutput("fecha_organoespecificas"),
      uiOutput("busqueda_organoespecificas")
      
    ),
    
    
    box(
      title = "Resultados de pubmend",
      status = "primary", solidHeader = T, width = 12,
      height = 450,
      dataTableOutput("pmidresult_organoesp")),
    
    
    htmlOutput("rows_selected_organoesp"),
    
    box(
      title = "Análisis de las publicaciones",
      status = "primary", solidHeader = T, width = 12,
      height = 230,
      
      column(width = 6, uiOutput("minimoorgano_espe")),
      column(width = 6, uiOutput("maximoorgano_espe")),
      uiOutput("crear_visualizacion2")
      
    ),
    
    
    tabBox(
      title = "",
      # The id lets us use input$tabset1 on the server to find the current tab
      id = "palabrasorgano",
      tabPanel("Nube de palabras", plotOutput("nubepalabrasorgano")),
      tabPanel("Tabla de palabras", dataTableOutput("palabras_organo"))
    ),
    
    
    tabBox(
      title = "",
      # The id lets us use input$tabset1 on the server to find the current tab
      id = "genesorgano",
      tabPanel("Nube de genes", plotOutput("nubegenesorgano")),
      tabPanel("Tabla de genes", dataTableOutput("tablagenesorgano"))
    )
    
    
  )
    
    
    
  )


