
### relaciones server


## enfermedades

genes <- c("addison","amyloidosis","celiac","crohn", 
  "fibromyalgia","granulomatosis with polyangiitis","graves", 
  "guillain-Barre","hashimoto","juvenile arthritis",                  
  "juvenile diabetes","kawasaki",                    
  "lambert-Eaton","sclerosis","myasthenia gravis",                   
  "psoriasis","rheumatoid arthritis","sarcoidosis","scleroderma", 
  "sjogren","ulcerative colitis",             
  "uveitis","vasculitis","vitiligo") 


pubmedResult2 <-eventReactive(input$downPub2, 
                             
                             {withProgress(message="Descargando informacion desde Pubmed", detail="Espere, por favor..",  
                                           value= 0, {incProgress(0.1,detail = "Espere, por favor..") 
                                             
                                             corpusEA<-batch_pubmed_download(pubmed_query_string =  
                                                                             paste(c("Autoimmune Diseases [MH] AND ",          
                                                                                     as.character("2019-02-01","%Y/%m/%d"), 
                                                                                     ":", as.character("2019-03-01","%Y/%m/%d"), 
                                                                                     " [DP]"),collapse = "" ), 
                                                                             format = "abstract", 
                                                                             batch_size = 2000, 
                                                                             dest_file_prefix = "corpusEA_") 
                                             
                                             
                                             incProgress(0.1, detail = "Consolidando archivos") 
                                             file.create("pubmed_result2.txt") 
                                             
                                             for (i in 1:length(corpusEA)){ 
                                               file.append("pubmed_result2.txt",corpusEA[i])} 
                                             
                                             corpus_query_comb<-readabs("pubmed_result2.txt") 
                                             
                                             incProgress(0.2, detail= "extrayendo genes") 
                                             
                                             
                                             genes_EA_comb<-data.frame(gene_atomization(corpus_query_comb),stringsAsFactors = FALSE) 
                                             
                                             genes_EA_comb$Freq<-as.numeric(genes_EA_comb$Freq) 
                                             
                                             genes_EA_list_comb<-genes_EA_comb[genes_EA_comb$Freq>10,1] 
                                             
                                             terms_lupus<-c("erythematosus","renal","rash","joint", "skin", "lung", 
                                                            "kidney","nephritis","glomerulonephritis", "autoimmune", "arthritis" ) 
                                             
                                             incProgress(0.1, detail= "LSA") 
                                             tdm_main <- tdm_for_lsa(corpus_query_comb,
                                                                     c(genes_EA_list_comb,
                                                                       "lupus",terms_lupus,
                                                                       genes)) 
                                             
                                             lsa_corpus<-lsa(tdm_main,dims=dimcalc_share()) 
                                             
                                             matriz<-as.textmatrix(lsa_corpus) 
                                             
                                             aa<-associate(matriz,"lupus",measure="cosine",threshold = 1e-399) 
                                             
                                             coseno_out<-data.frame(genes=names(aa),coseno=aa,stringsAsFactors = FALSE) 
                                             
                                             incProgress(0.1, detail= "publicaciones de Lupus") 
                                             
                                             output_lupus<-batch_pubmed_download(pubmed_query_string =paste(c("Lupus Erythematosus, 
Systemic [MH] AND ",          
                                                                                                              as.character("2019-02-01","%Y/%m/%d"), 
                                                                                                              ":", as.character("2019-03-01","%Y/%m/%d"), 
                                                                                                              " [DP]"),collapse = "" ),format = "abstract",batch_size = 1500,dest_file_prefix = "pubmedlupus") 
                                             
                                             
                                             
                                             
                                             #concatenar archivos 
                                             
                                             file.create("pubmed_result_lupus.txt") 
                                             for (i in 1:length(output_lupus)){ 
                                               file.append("pubmed_result_lupus.txt",output_lupus[i])} 
                                             
                                             
                                             corpus_lupus<-readabs("pubmed_result_lupus.txt") 
                                             
                                             incProgress(0.1, detail= "Genes asociados a Lupus") 
                                             genes_EA<-gene_atomization(corpus_lupus) 
                                             
                                             genes_EA_list<-genes_EA[,1] 
                                             
                                             genes_EA_list_lupus<-data.frame(genes=genes_EA_list,lupus="si",stringsAsFactors = FALSE) 
                                             
                                             
                                             result_genes<-merge(coseno_out,genes_EA_list_lupus,by.x = "genes", by.y = "genes",all.x = TRUE) 
                                             
                                             result_genes<-result_genes[!result_genes$genes %in% 
                                                                          c(terms_lupus,genes),] 
                                             
  
                                             funcion_relEA<-function(x){combine_words(names(associate(matriz,x,measure="cosine",threshold = 
                                                                                                        0.4))[which(names(associate(matriz,x,measure="cosine",threshold = 0.4)) %in% genes)], sep = 
                                                                                        ", ", and = " y "    ) 
                                             } 
                                             
                                             result_genes$otras_EAS<- lapply(result_genes$genes,funcion_relEA) 
                                             result_genes[result_genes$otras_EAS=="character(0)",4]<-NA 
                                             result_genes$coseno<-round(result_genes$coseno,5) 
                                             
                                             incProgress(0.3, detail= "Completo") 
                                             
                                             
                                             #row.names(result_genes)<-seq(1:length(result_genes$genes)) 
                                             
                                             mylist<-list("matriz"=matriz,"result_genes"=result_genes, "terms"=terms_lupus) 
                                             
                                             return(mylist) 
                                             
                                           }) 
                             } 
                             
                             
)  



output$pmidresult2<-renderDataTable({ 
  result_genes<-pubmedResult2()$result_genes 
  datatable(result_genes, colnames=c("Gen", "Similitud por coseno con Lupus", "Mencionado en publicaciones de 
Lupus","Otras EAs relacionadas") ,selection=list(mode='single',selected=1),options = list(lengthMenu = c(5, 30, 50), 
                                                                                          pageLength = 5, 
                                                                                          
                                                                                          order = list(list(1, 'desc')) 
                                                                                          
), rownames = FALSE) %>% formatStyle(names(result_genes),cursor = 
                                       'hand', target = "cell")%>%formatStyle(columns = 4, fontSize = '80%')%>%formatStyle(c("genes", "coseno", "lupus", 
                                                                                                                             "otras_EAS"), textAlign = 'center') 
  
  
}) 

output$relacionesgenes3D<-renderRglwidget({ 
  
  matriz<-pubmedResult2()$matriz 
  
  terms_lupus<-pubmedResult2()$terms 
  
  termMatrix2<-matriz%*%t(matriz) 
  
  exclude<-which(row.names(termMatrix2) %in% terms_lupus) 
  
  include<-which(row.names(termMatrix2) %in% c((pubmedResult2()$result_genes)$genes,"lupus")) 
  plot_neighbors("lupus",n=length(include),tvectors=matriz[include,include],legend=T,connect.lines = 0, alpha=c(0.8,0.8), col= 
                   c("lemonchiffon","orange","darkred")) 
  rglwidget() 
  
}) 