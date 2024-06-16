


enfermedades <- structure(list(Enfermedad = c("Systemic Lupus Erythematosus", "Rheumatoid Arthritis", "Systemic Sclerosis", 
                                              "Ankylosing Spondylitis", "Reactive Arthritis", "Polymyositis/Dermatomyositis", 
                                              "Sjögren's Syndrome", "Behçet's Syndrome", "Vasculitic Syndromes", 
                                              "Polyarteritis Nodosa", "Temporal Arteritis", "Takayasu's Arteritis", 
                                              "Kawasaki Disease", "Wegener's Granulomatosis", "Churg-Strauss Syndrome", 
                                              "Sarcoidosis"), 
                               Tipo = c("Enfermedad del tejido conectivo", "Enfermedad del tejido conectivo", 
                                        "Enfermedad del tejido conectivo", "Enfermedad del tejido conectivo", 
                                        "Enfermedad del tejido conectivo", "Enfermedad del tejido conectivo", 
                                        "Enfermedad del tejido conectivo", "Enfermedad del tejido mixto conectivo", 
                                        "Enfermedad del tejido mixto conectivo", "Enfermedad del tejido mixto conectivo", 
                                        "Enfermedad del tejido mixto conectivo", "Enfermedad del tejido mixto conectivo", 
                                        "Enfermedad del tejido mixto conectivo", "Enfermedad del tejido mixto conectivo", 
                                        "Enfermedad del tejido mixto conectivo", "Enfermedad del tejido mixto conectivo"
                               )), row.names = c(NA, -16L), class = "data.frame")


output$tipo_enfermedad <- renderUI({
  selectInput(inputId = "sistemicas",
              label = "Seleccione un tipo a mostrar",
              choices = enfermedades$Tipo|> unique(),
              selected = (enfermedades$Tipo |> unique())[1]
  )
  
})

output$enfermedad <- renderUI({
  selectInput(inputId = "enfermedad_sistemica",
              label = "Seleccione un tipo a mostrar",
              choices = enfermedades[enfermedades$Tipo == input$sistemicas, 
                                     1] |> unique(),
              selected = (enfermedades[enfermedades$Tipo == input$sistemicas, 
                                       1] |> unique())[1]
  )
})


output$fecha_sistemicas <- renderUI({
  
  dateRangeInput(inputId = "dates_sistemicas",
                 label = "Selecciona fecha de registros", 
                 start = "2019-01-01", end = "2019-02-01")
  
  
})


output$busqueda_sistemica <- renderUI({
  
  
  actionButton(inputId="Descargarsistematicas",label= paste(c(input$enfermedad_sistemica," [MH] AND ",  
                                                              gsub("-", "/", as.character(input$dates_sistemicas[1])), 
                                                              ":", 
                                                              gsub("-", "/", as.character(input$dates_sistemicas[2])), 
                                                              " [DP]"),collapse = "" ),
               icon=icon("download"),
               class = "text-center")
  
  
  
})




resultados <- eventReactive(input$Descargarsistematicas, {
  withProgress(
    message = "Descargando información desde PubMed",
    detail = "Espere, por favor...",
    value = 0,
    {
      
      corpus<-batch_pubmed_download(pubmed_query_string =  
                                      paste(c(input$enfermedad_sistemica," [MH] AND ",  
                                              gsub("-", "/", as.character(input$dates_sistemicas[1])), 
                                              ":", 
                                              gsub("-", "/", as.character(input$dates_sistemicas[2])), 
                                              " [DP]"),collapse = "" ), 
                                    format = "abstract", 
                                    batch_size = 2000, 
                                    dest_file_prefix = "corpus_") 
      
      
      incProgress(5/10, detail = "Consolidando archivos") 
      file.create("pubmed_result.txt") 
      
      for (i in 1:length(corpus)){ 
        file.append("pubmed_result.txt",corpus[i])} 
      
      corpus_output<-readabs("pubmed_result.txt") 
      incProgress(10/10, detail= "Completo") 
      return(corpus_output) 
      
      
    }
  )
})



output$pmidresult_sistematicas <-renderDataTable({ 
  corpus <- resultados()
  
  pmidAbs<-data.frame(abtracts=corpus@Abstract) 
  
  titulos<-c() 
  for (i in 1:length(corpus@PMID)){ 
    abstractnro<-i 
    text <- unlist(strsplit(corpus@Abstract[abstractnro], "\\.")) 
    op<-which(unlist(lapply(unlist(strsplit(corpus@Abstract[abstractnro], "\\.")), wordcount))>=6)[1] 
    titulos<-c(titulos,text[op]) 
  } 
  
  Intro=unlist(lapply(pmidAbs$abtracts,substr, start=1, stop=300)) 
  pmidRes<-data.frame(PMID=corpus@PMID,Titulo=titulos) 
  
  datatable(pmidRes,selection=list(mode='single',selected=1),
            options = list(lengthMenu = c(5, 30, 50), pageLength = 5 
  )) %>% formatStyle(names(pmidRes),cursor = 'hand', target = "cell") 
  
  
})


output$rows_selected_sistematicas<-renderPrint({ 
  
  corpus<- resultados() 
  
  text <- unlist(strsplit(corpus@Abstract[input$pmidresult_sistematicas_rows_selected], "\\.")) 
  op<-which(unlist(lapply(unlist(strsplit(corpus@Abstract[input$pmidresult_sistematicas_rows_selected], "\\.")), wordcount))>=6)[1] 
  titulos<-text[op] 
  
  
  for (i in 1:length(text)){ 
    
    if (i==op)cat(paste('<p><h4>','<font  color=\"#4B04F6\"><b>',text[i],'</b></font>','</h4>','\n','<p>'),fill=TRUE) 
    
    else cat(paste('<SPAN class=texto-pequeno><i>',text[i],".",'</i></SPAN>'),fill=TRUE)     
    
    
  } 
  
  
  cat(paste("<p><a 
href='https://www.ncbi.nlm.nih.gov/pubmed/",corpus@PMID[input$pmidresult_rows_selected],"'target=_blank>", "Link a 
publicacion en Pubmed","</a><p>")) 
  
})


### analisis de publicaciones

output$minimosistemicas <- renderUI({ sliderInput("minpalabras", label="Freq minima de palabras", 
                             min=1, max=10, value=5) })

output$maximosistemicas <- renderUI({ sliderInput("maxpalabras", label="Máximo de palabras", 
                             min=1, max=500, value=100) })



### crear tablas
output$crear_visualizacion <- renderUI({
  
  
  actionButton(inputId="Visuales_sistematicas",
               label= "Crear visualizaciones",
               icon=icon("chart-simple"),
               class = "text-center")
  
  
  
})

### grafico palabras

grafico_palabras <- eventReactive(input$Visuales_sistematicas,{


              withProgress(message="Procesando Corpus", detail="Espere, por favor..",  
                           value= 0, {incProgress(2/10,detail = "Espere, por favor..") 
                             
                             corpus<-  resultados() 
                             words<-word_atomizations(corpus) 
                             row.names(words)<-NULL 
                             
                             incProgress(8/10, detail = "Generando nube de palabras") 
                             
                             wordcloud(words$words,words$Freq,max.words = input$maxpalabras, min.freq = input$minpalabras ,  
                                       random.color = TRUE, colors = brewer.pal(8,"Dark2"),scale = c(4, 0.5)) 
                             
                           }) })



### tabla de palabras 

tabla_palabras <- eventReactive(input$Visuales_sistematicas,{
  corpus<-  resultados() 
  words<-word_atomizations(corpus) 
  colnames(words)<-c("Palabra","Frecuencia") 
  datatable(words, rownames = FALSE)
  
  })


### nube de palabras

output$nubepalabrassistema <-renderPlot({  
  
  grafico_palabras()
  })


output$palabras_sistema <-renderDataTable({ 
  tabla_palabras()
}) 


### nube de genes



grafico_palabras <- eventReactive(input$Visuales_sistematicas,{
  
  
  withProgress(message="Procesando Corpus", detail="Espere, por favor..",  
               value= 0, {incProgress(2/10,detail = "Espere, por favor..") 
                 
                 corpus<-  resultados() 
                 words<-word_atomizations(corpus) 
                 row.names(words)<-NULL 
                 
                 incProgress(8/10, detail = "Generando nube de palabras") 
                 
                 wordcloud(words$words,words$Freq,max.words = input$maxpalabras, min.freq = input$minpalabras ,  
                           random.color = TRUE, colors = brewer.pal(8,"Dark2"),scale = c(4, 0.5)) 
                 
               }) })


wordcloudRep<-repeatable(wordcloud) 

grafico_genes <- eventReactive(input$Visuales_sistematicas,{
  
  withProgress(message="Procesando Corpus", detail="Espere, por favor..",  
               value= 0, {incProgress(2/10,detail = "Espere, por favor..") 
                 
                 corpus<- resultados() 
                 
                 incProgress(8/10, detail = "Generando nube de genes") 
                 
                 freqGenes<-data.frame(gene_atomization(corpus),stringsAsFactors = FALSE) 
                 
                 
      wordcloudRep(words=freqGenes$Gene_symbol,freq=as.numeric(freqGenes$Freq),max.words = input$maxpalabras, 
                   min.freq = input$minpalabras,  
                   random.color = TRUE, colors = brewer.pal(8,"Dark2"),scale = c(8, 0.6)) 
       
               })}) 


tabla_genes <- eventReactive(input$Visuales_sistematicas,{
          
  withProgress(message="Creando tabla de genes", detail="Espere, por favor..",{
               
              corpus<- resultados() 
              
              freqGenes<-data.frame(gene_atomization(corpus),
                                    stringsAsFactors = FALSE) 
              
              colnames(freqGenes)<-c("Simbolo","Nombre","Frecuencia") 
              datatable(freqGenes, rownames = FALSE)})

})


output$nubegenessistema <-renderPlot(width = "auto", height = "auto",{  
  
  grafico_genes()
  
})




output$tablagenessistema <-renderDataTable({ 
  
  tabla_genes()
  
}) 