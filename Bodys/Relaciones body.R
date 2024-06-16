

##### body de relaciones enfermedad

fluidPage(
  
  fluidRow(
    
    h2("Relaciones entre genes y Lupus Eritematoso",align="center"),
    
    p("Seleccionar un período para la búsqueda bibliográfica bajo la etiqueta 
MESH:Autoinmune Diseases. Se obtiene un listado de genes relacionados a enfermedades autoinmunes distinguiendo 
aquellos que hayn sido explícitamente mencioandos en abstracts de Pubmed clasificados bajo la etiqueta MESH:Lupus 
Erythematosus, Systemic. Al seleccionar un gen de la lista puede realizarse una búsqueda en Pubmed del tipo: Lupus AND 
nombre del gen -sin etiquetas MeSH- para explorar pubicaciones. De no hallarse publicaciones, esta herramienta puede 
sugerir nuevos genes relacionados con el Lupus no descritos en bibliografía aún."),
    
    box(id="seleccEA", 
        title = "Seleccione  la información a mostrar:", solidHeader = T, 
        status = "primary", width = 12,
        
       
        
        column(width = 6,
        dateInput(inputId = "refechas","Desde fecha:",
                  value = "2019-01-01",format = "yyyy-mm-dd")), 
        
        column(width = 6,
        dateInput("refechas2","Hasta fecha:",
                  value = "2019-02-01",
                  format = "yyyy-mm-dd")), 
        
        actionButton(inputId="downPub2",label="Buscar información",
                     color="primary",style="gradient", 
                     icon=icon("download")),
        
        
        
        dataTableOutput("pmidresult2")
        
       
    
  )
)
)