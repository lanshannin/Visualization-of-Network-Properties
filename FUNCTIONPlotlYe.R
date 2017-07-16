source("FUNCTIONTwoside.R")             #Twoside ��funtion
source("FUNCTIONNode.select.R")         #Node_Select ��funtion
source("FUNCTIONtriangle.numggplot.R")   
source("FUNCTIONeach.datatable.R")   
PlotlY1<-function(MATRIX,group,gname,firstdate,
                  ICON.CODEg="f111",ICON.SIZEg=50,
                  ICON.CODE1=c("f005","f185"),ICON.COLOR1=c("yellow","red"),ICON.SIZE1=c(50,70),icon.sizeL1=20,ICON.LABEL1=c("one link company","company"),
                  ICON.CODE2=rep("f19c",length(unique(group))),ICON.COLOR2=unique(ColoR),ICON.LABEL2=unique(group)){
  
  visGroup=FUNCTIONTwoside(MATRIX,group,gname,firstdate,ICON.CODEg,ICON.COLOR2,ICON.SIZEg)
  dataeach=datateach(MATRIX,group,gname,firstdate)
  visNode_selection=FUNCTIONNode_selection(MATRIX,group,firstdate,ICON.CODE2,ICON.COLOR2)
  ptri=TriangleNumggplot(MATRIX,group,gname,firstdate)
  
ui = pageWithSidebar(
    headerPanel("Network Property!"),
    sidebarPanel(
        selectInput("Date", "Year-Month:"  ,choices = as.character(Date)),
               
        conditionalPanel(condition="input.tabselected==3"
                                ,selectInput(inputId = "selnodes", label = "Node selection", choices = 1:length(group), multiple = TRUE)),
               conditionalPanel(condition="input.tabselected==4",
                                selectInput(inputId = "dg", label =  "In-Degree",
                                            choices=sort(unique(indeg[[i]]))) ) ,
               conditionalPanel(condition="input.tabselected==5",
                                selectInput(inputId = "dgout", label =  "Out-Degree",
                                            choices=sort(unique(outdeg[[i]]))) ) ,
               conditionalPanel(condition="input.tabselected==6")
             ),
             mainPanel(
               tabsetPanel(
                 tabPanel("Property Table", value=1,dataTableOutput("table1") ),
                 tabPanel("Group", value=2,visNetworkOutput("grou", height = "750px")),
                 tabPanel("Node", value=3,visNetworkOutput("visNode.select", height = "750px")),
                 tabPanel("In-Degree", value=4,  visNetworkOutput("Net_deg", height = "750px")), 
                 tabPanel("Out-Degree", value=5,  visNetworkOutput("Net_outdeg", height = "750px")), 
                 tabPanel("Triangle Number", value=6, plotlyOutput("Triangle.Number")),
                 id = "tabselected"
               )
             )
)

server=function(input, output,session) ({
  if (interactive()) {
    observe({
      i = which(as.character(Date)==as.character(input$Date) )[1];
      
      updateSelectInput(session, inputId = "dg", label ="In-Degree",
                        choices=sort(unique(indeg[[i]])))
      updateSelectInput(session,inputId = "dgout", label ="Out-Degree",
                        choices=sort(unique(outdeg[[i]])))
      updateSliderInput(session,"size", "degree", min = 0, max = max(deg[[i]]))
    })
  }
  
## Get the value of the MATRIX that is selected by user from the list of datasets
  data <- reactive({
    get(input$MATRIX)
  })
#----------------------------------------- 
##data table
  dataInput <- reactive({
    i = which(as.character(Date)==as.character(input$Date) )[1] 
    dataeach[[i]]
  })
  output$table1 <- renderDataTable({
    datatable(dataInput())
  })
  
#-----------------------------------------    
##�ϥΪ̥i�H��ܸ`�I�էO(group)
  output$grou <- renderVisNetwork({
    i = which(as.character(Date)==as.character(input$Date) )[1];
    visGroup[[i]]
  })
#-----------------------------------------  
##�ϥΪ̥i�H��ܺ����Ϥ����h�Ӹ`�I(nodes_selection)
  output$visNode.select <- renderVisNetwork({
    i = which(as.character(Date)==as.character(input$Date) )[1];
    visNode_selection[[i]]
  })
  
  observe({
    nodes_selection <- input$selnodes
    visNetworkProxy("visNode.select") %>%
      visSelectNodes(id = nodes_selection)
  })
#-----------------------------------------  
##�ϥΪ̥i�H��ܺ����Ϥ���IN-degree
  output$Net_deg <- renderVisNetwork({
    i = which(as.character(Date)==as.character(input$Date) )[1];
    
#�ƧǲէO�A�N��Ưx�}�̷�group�h���Ƨ�
    SSort=sort(paste(group),index.return=TRUE)
    RMATRIX[[i]]=MATRIX[[i]][SSort$ix,]
    CMATRIX[[i]]=RMATRIX[[i]][,SSort$ix]
#matrix�নigraph
    Mgfam[[i]]<- graph_from_adjacency_matrix(CMATRIX[[i]])      
    indeg[[i]] <- degree(Mgfam[[i]], mode="in")
    
    dg=input$dg;
#���indegree���`�I
    select.edgein[[i]]<-which(indeg[[i]]==dg)

if(dg==0){
      id[[i]]=select.edgein[[i]]    #�Ӷ��M�P�Pid
      sunid[[i]]=select.edgein[[i]] #�Ӷ�id
      starid[[i]]=id[[i]][-which(id[[i]]==select.edgein[[i]])]#�P�Pid
      
      #�]�w�`�I�ϥ�(icon.code),�`�I�C��(icon.color)����
      iconcode=ifelse(id[[i]]==sunid[[i]],ICON.CODE1[2],ICON.CODE1[1])
      iconcolor=ifelse(id[[i]]==sunid[[i]],ICON.COLOR1[2],ICON.COLOR1[1])
      iconsize=ifelse(id[[i]]==sunid[[i]],ICON.SIZE1[2],ICON.SIZE1[1])
      #�վ�legend���ϥ�
      ADDNodein <- data.frame(label =ICON.LABEL1, shape = "icon",
                              icon.code = ICON.CODE1, icon.size =rep(icon.sizeL1,length(ICON.CODE1)), icon.color =ICON.COLOR1,font.color ="midnightblue")
      #�վ�`�I�T��
      indeg0_node[[i]]=data.frame(id=id[[i]],
                                   label=id[[i]],
                                   group= group[id[[i]]] ,
                                   title = paste0("Node:", id[[i]],"<br>Group:", group[id[[i]]],"<br>Name:",gname[id[[i]]]),
                                   shape = "icon",
                                   icon.code = iconcode,
                                   icon.color =iconcolor,
                                   icon.size=iconsize,
                                   font.size=iconsize-5,
                                   font.color=rep("midnightblue",length(id[[i]])))
      #�վ���T��
      indeg0_edge[[i]]<- data.frame(from = id[[i]],to = id[[i]])
      #������
      visNetwork(indeg0_node[[i]],indeg0_edge[[i]],
                 main = list(text = paste("In-degree",dg),
                             style = "ont-family:Georgia;color:#1a2421;font-size:25px;font-weight:bold;text-align:center;"),
                 submain=  list(text = paste("Date : ",Date[i],"<br>Node",paste( select.edgein[[i]], collapse = ", ")),
                                style = "font-family:Comic;color:#1a2421;font-size:18px;text-align:center;"),
                 width = "100%") %>%
        addFontAwesome() %>%
        addIonicons()%>%
        visOptions(highlightNearest = list(enabled = TRUE, hover = T, 
                                           hideColor = 'rgba(200,200,200,0)', degree = list(to =1)))%>%
        visEdges( hidden=TRUE)%>%   #edge�u����
        visLegend(addNodes =ADDNodein, useGroups = FALSE)
    }else{
      indegposi[[i]]=which(get.edgelist(Mgfam[[i]])[,2] %in% select.edgein[[i]])

      indegedgelist[[i]]<-matrix(get.edgelist(Mgfam[[i]])[indegposi[[i]],],ncol=2)  #edgelist
      id[[i]]=unique(c(indegedgelist[[i]][,1],indegedgelist[[i]][,2]))
      sunid[[i]]=select.edgein[[i]] #�Ӷ�id
      starid[[i]]=id[[i]][-which(id[[i]] %in% select.edgein[[i]])]#�P�Pid
      
      #�]�w�`�I�ϥ�(icon.code),�`�I�C��(icon.color)����
      iconcode1=ifelse(id[[i]]%in%sunid[[i]],ICON.CODE1[2],ICON.CODE1[1])
      iconcolor1=ifelse(id[[i]]%in%sunid[[i]],ICON.COLOR1[2],ICON.COLOR1[1])
      iconsize1=ifelse(id[[i]] %in% sunid[[i]],ICON.SIZE1[2],ICON.SIZE1[1])
      #�վ�legend���ϥ�
      ADDNodein <- data.frame(label =ICON.LABEL1, shape = "icon",
                              icon.code = ICON.CODE1, icon.size =rep(icon.sizeL1,length(ICON.CODE1)),icon.color =ICON.COLOR1, font.color ="midnightblue")
      #�վ���T��
      indeg_edge[[i]]<- data.frame(from =indegedgelist[[i]][,1], to = indegedgelist[[i]][,2])
      #�վ�`�I�T��
      indeg_node[[i]]=data.frame(id=id[[i]],
                                  label=id[[i]],
                                  group=group[id[[i]]] ,
                                  title = paste0("Node:", id[[i]],"<br>Group:", group[id[[i]]],"<br>Name:",gname[id[[i]]]),
                                  shape = "icon",
                                  icon.code = iconcode1,
                                  icon.color =iconcolor1,
                                  icon.size=iconsize1,
                                  font.size=iconsize1-15,
                                  font.color=rep("midnightblue",length(id[[i]])))
      #������ 
      visNetwork(indeg_node[[i]],indeg_edge[[i]],
                 main = list(text = paste("In-degree",dg),
                             style = "ont-family:Georgia;color:#1a2421;font-size:25px;font-weight:bold;text-align:center;"),
                 submain=list(text = paste("Date : ",Date[i],"<br>Node",paste( select.edgein[[i]], collapse = ", ")),
                              style = "font-family:serif;color:#1a2421;font-size:18px;text-align:center;"),
                 width = "100%") %>%
        addFontAwesome() %>%
        addIonicons()%>%
        visEdges(color=list(color = "white", highlight = "cyan",opacity=0.15),#hidden=TRUE,  #edge�u����
                 arrows =list(to = list(enabled = TRUE, scaleFactor = 1))
                 ,dashes = TRUE
                 ,arrowStrikethrough=FALSE) %>%
        visOptions( highlightNearest = list(enabled = TRUE, algorithm = "hierarchical",
                                            hover = T, hideColor = 'rgba(200,200,200,0)', degree = list(from =1)))  %>%
        visPhysics(solver = "repulsion")%>%
        visInteraction(keyboard = TRUE, dragNodes = T, dragView = T, zoomView = T ) %>%
        visLegend(addNodes = ADDNodein , useGroups = FALSE)
    }
  })
#-----------------------------------------
##�ϥΪ̥i�H��ܺ����Ϥ���OUT-degree
  output$Net_outdeg <- renderVisNetwork({
    i = which(as.character(Date)==as.character(input$Date) )[1];

#�ƧǲէO�A�N��Ưx�}�̷�group�h���Ƨ�
    SSort=sort(paste(group),index.return=TRUE) 
    RMATRIX[[i]]=MATRIX[[i]][SSort$ix,]
    CMATRIX[[i]]=RMATRIX[[i]][,SSort$ix]
#matrix�নigraph    
    Mgfam[[i]]<- graph_from_adjacency_matrix(CMATRIX[[i]])      
#�p��outdegree 
    outdeg[[i]] <- degree(Mgfam[[i]],mode="out")
    
    dg=input$dgout;
#���OUTdegree���`�I
    select.edgeout[[i]]<-which(outdeg[[i]]==dg)
if(dg==0){
      id[[i]]=select.edgeout[[i]]    #�Ӷ��M�P�Pid
      sunid[[i]]=select.edgeout[[i]] #�Ӷ�id
      starid[[i]]=id[[i]][-which(id[[i]]==select.edgeout[[i]])]#�P�Pid
      
      #�]�w�`�I�ϥ�(icon.code),�`�I�C��(icon.color)����
      iconcode=ifelse(id[[i]]==sunid[[i]],ICON.CODE1[2],ICON.CODE1[1])
      iconcolor=ifelse(id[[i]]==sunid[[i]],ICON.COLOR1[2],ICON.COLOR1[1])
      iconsize=ifelse(id[[i]]==sunid[[i]],ICON.SIZE1[2],ICON.SIZE1[1])
      #�վ�legend���ϥ�
      ADDNodeout <- data.frame(label =ICON.LABEL1, shape = "icon",
                               icon.code = ICON.CODE1, icon.size =rep(icon.sizeL1,length(ICON.CODE1)), icon.color =ICON.COLOR1,font.color ="midnightblue")
      #�վ�`�I�T��
      outdeg0_node[[i]]=data.frame(id=id[[i]],
                                    label=id[[i]],
                                    group= group[id[[i]]] ,
                                    title = paste0("Node:", id[[i]],"<br>Group:", group[id[[i]]],"<br>Name:",gname[id[[i]]]),
                                    shape = "icon",
                                    icon.code = iconcode,
                                    icon.color =iconcolor,
                                    icon.size=iconsize,
                                    font.size=iconsize-5,
                                    font.color=rep("midnightblue",length(id[[i]])))
      #�վ���T��
      outdeg0_edge[[i]]<- data.frame(from =id[[i]],to =id[[i]])
      #������ 
      visNetwork(outdeg0_node[[i]], outdeg0_edge[[i]],
                 main = list(text = paste("Out-degree",dg),
                             style = "ont-family:serif;color:	#1a2421;font-size:25px;font-weight:bold;text-align:center;"),
                 submain=  list(text = paste("Date : ",Date[i],"<br>Node",paste( select.edgeout[[i]], collapse = ", ")),
                                style = "font-family:Comic;color:	#1a2421;font-size:18px;text-align:center;"),    
                 width = "100%") %>%
      addFontAwesome() %>%
      addIonicons()%>%
      visOptions( highlightNearest = list(enabled = TRUE, hover = T, hideColor = 'rgba(200,200,200,0)', 
                                  degree = list(to =1)))%>%
      visEdges( hidden=TRUE)%>%   
      visLegend(addNodes =ADDNodeout,useGroups = FALSE)  
    }else{
      outdegposi[[i]]=which(get.edgelist(Mgfam[[i]])[,1] %in% select.edgeout[[i]])

      outdegedgelist[[i]]<-matrix(get.edgelist(Mgfam[[i]])[outdegposi[[i]],],ncol=2)  #edgelist
      id[[i]]=unique(c(outdegedgelist[[i]][,1],outdegedgelist[[i]][,2]))
      sunid[[i]]=select.edgeout[[i]] #�Ӷ�id
      starid[[i]]=id[[i]][-which(id[[i]] %in% select.edgeout[[i]])]#�P�Pid
      
      #�]�w�`�I�ϥ�(icon.code),�`�I�C��(icon.color)����
      iconcode1=ifelse(id[[i]]%in%sunid[[i]],ICON.CODE1[2],ICON.CODE1[1])
      iconcolor1=ifelse(id[[i]]%in%sunid[[i]],ICON.COLOR1[2],ICON.COLOR1[1])
      iconsize1=ifelse(id[[i]] %in% sunid[[i]],ICON.SIZE1[2],ICON.SIZE1[1])
      #�վ�legend���ϥ�
      ADDNodeout <- data.frame(label =ICON.LABEL1, shape = "icon",
                               icon.code = ICON.CODE1, icon.size =rep(icon.sizeL1,length(ICON.CODE1)),icon.color =ICON.COLOR1, font.color ="midnightblue")
      #�վ���M�`�I���T��
      outdeg_edge[[i]] <- data.frame(from =outdegedgelist[[i]][,1], to = outdegedgelist[[i]][,2])
      outdeg_node[[i]] = data.frame(id=id[[i]],
                                   label=id[[i]],
                                   group=group[id[[i]]] ,
                                   title = paste0("Node:", id[[i]],"<br>Group:", group[id[[i]]],"<br>Name:",gname[id[[i]]]),
                                   shape = "icon",
                                   icon.code = iconcode1,
                                   icon.color =iconcolor1,
                                   icon.size=iconsize1,
                                   font.size=iconsize1-15,
                                   font.color=rep("midnightblue",length(id[[i]])))
      
      #������
      visNetwork(outdeg_node[[i]],outdeg_edge[[i]],
                 main = list(text = paste("Out-degree",dg),
                             style = "ont-family:serif;color:	#1a2421;font-size:25px;font-weight:bold;text-align:center;"),
                 submain=list(text = paste("Date : ",Date[i],"<br>Node",paste( select.edgeout[[i]], collapse = ", ")),
                              style = "font-family:Comic;color:	#1a2421;font-size:18px;text-align:center;"),    
                 width = "100%") %>%
        addFontAwesome() %>%
        addIonicons()%>%
        visEdges(color=list(color = "white", highlight = "cyan",opacity=0.15),#hidden=TRUE,  #edge�u����
                 arrows =list(to = list(enabled = TRUE, scaleFactor = 1))
                 ,dashes = TRUE
                 ,arrowStrikethrough=FALSE) %>%   
        visOptions( highlightNearest = list(enabled = TRUE, algorithm = "hierarchical",
                                            hover = T, hideColor = 'rgba(200,200,200,0)',degree = list(to =1)) ) %>% 
        visPhysics(solver = "repulsion")%>%
        visInteraction(keyboard = TRUE, dragNodes = T, dragView = T, zoomView = T ) %>%
        visLegend(addNodes = ADDNodeout , useGroups = FALSE)
    }
  })
#-----------------------------------------
##�`�I�b�������ѻP���T���μƪ����
  output$Triangle.Number <- renderPlotly({
    i = which(as.character(Date)==as.character(input$Date) )[1];
    ptri[[i]]
  })
})
result <-list(server = server,ui=ui)
Shiny.ResulTe<-shinyApp(server = result$server,ui= result$ui)
return(Shiny.ResulTe) 
}