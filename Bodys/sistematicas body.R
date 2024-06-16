
### body de enfermedades sistematicas




fluidPage(
  
  ### mapa
  ### rmd sobre el sanitario de la vivienda
  fluidRow(
    titlePanel("Filtros para enfermedades autoinmunitarias sistémicas"),
    
    box(
      title = "Seleccione el tipo y la enfermedad a buscar",
      status = "primary", solidHeader = T, width = 12,
      height = 330,
      uiOutput("tipo_enfermedad"),
      uiOutput("enfermedad"),
      uiOutput("fecha_sistemicas"),
      uiOutput("busqueda_sistemica")
    ),
    
    
    box(
      title = "Resultados de pubmend",
      status = "primary", solidHeader = T, width = 12,
      height = 450,
      dataTableOutput("pmidresult_sistematicas")),
    
   
    htmlOutput("rows_selected_sistematicas"), 
    
    box(
      title = "Análisis de las publicaciones",
      status = "primary", solidHeader = T, width = 12,
      height = 230,
      
      column(width = 6, uiOutput("minimosistemicas")),
      column(width = 6, uiOutput("maximosistemicas")),
      uiOutput("crear_visualizacion")
      
    ),
    
    
    tabBox(
      title = "",
      # The id lets us use input$tabset1 on the server to find the current tab
      id = "palabrassistema",
      tabPanel("Nube de palabras", plotOutput("nubepalabrassistema")),
      tabPanel("Tabla de palabras", dataTableOutput("palabras_sistema"))
    ),
    
    
    tabBox(
      title = "",
      # The id lets us use input$tabset1 on the server to find the current tab
      id = "tabset1",
      tabPanel("Nube de genes", plotOutput("nubegenessistema")),
      tabPanel("Tabla de genes", dataTableOutput("tablagenessistema"))
    )
    
    )
  
  
)