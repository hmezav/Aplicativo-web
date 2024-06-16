

enfermedades2 <-  data.frame(
  Categoria = c("Tiroides", "Tiroides", "Sistema Nervioso", "Sistema Nervioso", "Músculo", "Corazón", "Estómago", "Intestino", "Intestino", "Intestino", 
                "Glándula Suprarrenal", "Páncreas", "Piel", 
                "Piel", "Piel", "Hígado", "Hígado", "Hígado", 
                "Hematológicas", "Hematológicas"),
  Enfermedad = c("Tiroiditis De Hashimoto", "Enfermedad De Graves", 
                 "Esclerosis Múltiple", "Síndrome de Guillain-Barré",
                 "Miastenia Gravis", "Fiebre Reumática", "Anemia Perniciosa", 
                 "Enfermedad De Crohn", "Colitis Ulcerativa", 
                 "Enfermedad Celiaca", "Enfermedad de Addison", 
                 "Diabetes Tipo 1 Autoinmunitaria", "Pénfigo", 
                 "Psoriasis", "Vitíligo", "Hepatitis Autoinmunitaria", 
                 "Colangitis Esclerosante", "Cirrosis Biliar Primaria", 
                 "Anemias Hemolíticas", "Púrpura Trombocitopénica Autoinmunitaria"),
  
  Enfermedad_ingles = c("Hashimoto's Thyroiditis", "Graves' Disease", 
                        "Multiple Sclerosis", 
                                              "Guillain-Barré Syndrome", 
                                              "Myasthenia Gravis", 
                                              "Rheumatic Fever", 
                                              "Pernicious Anemia",
                                              "Crohn's Disease", 
                                              "Ulcerative Colitis", 
                                              "Celiac Disease", "Addison's Disease",
                                              "Type 1 Autoimmune Diabetes",
                                              "Pemphigus", "Psoriasis",
                                              "Vitiligo", "Autoimmune Hepatitis",
                                              "Primary Sclerosing Cholangitis",
                                              "Primary Biliary Cirrhosis", 
                                              "Hemolytic Anemias", 
                                              "Autoimmune Thrombocytopenic Purpura")
)


### filtros para el body del grafico


output$tipo_enfermedad2 <- renderUI({
  selectInput(inputId = "organoespecificas",
              label = "Seleccione una categoria",
              choices = enfermedades2$Categoria |> unique(),
              selected = (enfermedades2$Categoria |> unique())[1]
  )
  
})

output$enfermedad2 <- renderUI({
  selectInput(inputId = "Enfermeorganoespec",
              label = "Seleccione un tipo a mostrar",
              choices = enfermedades2[enfermedades2$Categoria == input$organoespecificas, 
                                     3] |> unique(),
              selected = (enfermedades2[enfermedades2$Categoria == input$organoespecificas, 
                                        3] |> unique())[1]
  )
})


output$fecha_organoespecificas <- renderUI({
  
  dateRangeInput(inputId = "date_organoespecificas",
                 label = "Selecciona fecha de registros", 
                 start = "2018-01-01", end = "2019-01-01")
  
  
})


output$busqueda_organoespecificas <- renderUI({
  
  
  actionButton(inputId="Descargar_organoespecifica",label=paste(c(input$Enfermeorganoespec," [MH] AND ",  
                                               gsub("-", "/", as.character(input$date_organoespecificas[1])), 
                                               ":", 
                                               gsub("-", "/", as.character(input$date_organoespecificas[2])), 
                                               " [DP]"),collapse = "" ),
               icon=icon("download"),
               class = "text-center")
})





resultados2 <- eventReactive(input$Descargar_organoespecifica, {
  withProgress(
    message = "Descargando información desde PubMed",
    detail = "Espere, por favor...",
    value = 0,
    {
      
      corpus<-batch_pubmed_download(pubmed_query_string =  
                                      paste(c(input$Enfermeorganoespec," [MH] AND ",  
                                              gsub("-", "/", as.character(input$date_organoespecificas[1])), 
                                              ":", 
                                              gsub("-", "/", as.character(input$date_organoespecificas[2])), 
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



output$pmidresult_organoesp <-renderDataTable({ 
  corpus <- resultados2()
  
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



output$rows_selected_organoesp<- renderPrint({ 
  
  corpus<- resultados2() 
  
  text <- unlist(strsplit(corpus@Abstract[input$pmidresult_organoesp_rows_selected], "\\.")) 
  op<-which(unlist(lapply(unlist(strsplit(corpus@Abstract[input$pmidresult_organoesp_rows_selected], "\\.")), wordcount))>=6)[1] 
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

output$minimoorgano_espe <- renderUI({ sliderInput("minpalabrasorgano", label="Freq minima de palabras", 
                                                  min=1, max=10, value=5) })

output$maximoorgano_espe <- renderUI({ sliderInput("maxpalabrasorgano", label="Máximo de palabras", 
                                                  min=1, max=500, value=100) })



### crear tablas
output$crear_visualizacion2 <- renderUI({
  
  
  actionButton(inputId="Visuales_organo_esp",
               label= "Crear visualizaciones",
               icon=icon("chart-simple"),
               class = "text-center")
  
  
  
})

### grafico palabras

grafico_palabras2 <- eventReactive(input$Visuales_organo_esp,{
  
  
  withProgress(message="Procesando Corpus", detail="Espere, por favor..",  
               value= 0, {incProgress(2/10,detail = "Espere, por favor..") 
                 
                 corpus<-  resultados2()
                 words<-word_atomizations(corpus) 
                 row.names(words)<-NULL 
                 
                 incProgress(8/10, detail = "Generando nube de palabras") 
                 
                 wordcloud(words$words,words$Freq,max.words = input$maxpalabrasorgano, min.freq = input$minpalabrasorgano ,  
                           random.color = TRUE, colors = brewer.pal(8,"Dark2"),scale = c(4, 0.5)) 
                 
               }) })



### tabla de palabras 

tabla_palabras2 <- eventReactive(input$Visuales_organo_esp,{
  corpus<-  resultados2()
  words<-word_atomizations(corpus) 
  colnames(words)<-c("Palabra","Frecuencia") 
  datatable(words, rownames = FALSE)
  
})


### nube de palabras

output$nubepalabrasorgano <-renderPlot({  
  
  grafico_palabras2()
})


output$palabras_organo <-renderDataTable({ 
  tabla_palabras2()
}) 


### nube de genes


wordcloudRep<-repeatable(wordcloud) 

grafico_genes2 <- eventReactive(input$Visuales_organo_esp,{
  
  withProgress(message="Procesando Corpus", detail="Espere, por favor..",  
               value= 0, {incProgress(2/10,detail = "Espere, por favor..") 
                 
                 corpus<- resultados2()
                 
                 incProgress(8/10, detail = "Generando nube de genes") 
                 
                 freqGenes<-data.frame(gene_atomization(corpus),stringsAsFactors = FALSE) 
                 
                 
                 wordcloudRep(words=freqGenes$Gene_symbol,freq=as.numeric(freqGenes$Freq),max.words = input$maxpalabrasorgano, 
                              min.freq = input$minpalabrasorgano,  
                              random.color = TRUE, colors = brewer.pal(8,"Dark2"),scale = c(8, 0.6)) 
                 
               })}) 


tabla_genes2 <- eventReactive(input$Visuales_organo_esp,{
  
  withProgress(message="Creando tabla de genes", detail="Espere, por favor..",{
    
    corpus<- resultados2()
    
    freqGenes<-data.frame(gene_atomization(corpus),
                          stringsAsFactors = FALSE) 
    
    colnames(freqGenes)<-c("Simbolo","Nombre","Frecuencia") 
    datatable(freqGenes, rownames = FALSE)})
  
})


output$nubegenesorgano <-renderPlot(width = "auto", height = "auto",{  
  
  grafico_genes2()
  
})




output$tablagenesorgano <-renderDataTable({ 
  
  tabla_genes2()
  
}) 