datatnei=list()
OneinoutF<- function(MATRIX,group,gname,firstdate){
##�]�w���  
  Date0 <- seq.Date(from = as.Date(firstdate,format = "%Y-%m-%d"), by = "month", length.out =length(MATRIX))
  Date <- format(Date0, format = "%Y-%m")

##�C�X�@�Ӻ�����date�Bid�Bindegree�Boutdegree��dataframe���
ID=c(1:dim(MATRIX[[i]])[1])  #�`�I��
for(i in 1:length(MATRIX)){  
  SSort=sort(paste(group),index.return=TRUE) 
  RMATRIX[[i]]=MATRIX[[i]][SSort$ix,]
  CMATRIX[[i]]=RMATRIX[[i]][,SSort$ix]
  
  Mgfam[[i]]<- graph_from_adjacency_matrix(CMATRIX[[i]]) 
  
  indeg[[i]]<-degree(Mgfam[[i]], mode="in")
  outdeg[[i]]<-degree(Mgfam[[i]], mode="out")
  datatnei[[i]]=data_frame(Date[i],ID, indeg[[i]], outdeg[[i]])
  colnames(datatnei[[i]])= c("Date","ID",'InDegree', 'OutDegree')
}
###########################################################
###�z���Ƭ����qj�B�tdate indegree outdegree����ơA�C�����q��36�Ӻ����A�ҥH�O36�Ӥ�����
###IDdata�̦�71��dataframe �A�C��dataframe���@�a���q�A�ҥH�@71�a���q�A�ӨC�a���q��36�Ӥ�������
IDdata=list()
for(j in 1:length(ID)){
  iddata=c()
  for(i in 1:length(MATRIX)){
    idD=subset(datatnei[[i]],datatnei[[i]]$ID==j, select=c(1,2,3,4))
    idD <- do.call(cbind.data.frame, idD) 
    iddata=rbind(iddata,idD) 
  }
  IDdata[[j]]=iddata  
}
###########################################################
###��@�����q�b�@�Ӥ��(i.e.�@�ӯx�})���U��indegree(�@��>0�����q)�Boutdegree(�@�C>0�����q)
###�N�@�����q�b36�Ӯɶ��������ΡA�إߪ�dataframe�s�JOneinout�A�ҥHOneinout��71��dataframe�A
#  �ӨC��dataframe�N���@�����q��to �Bfrom��H����
Oneinout=list()

for(k in 1:dim(CMATRIX[[i]])[1]){    #k���ĴX�����q
  oneinout=c()
  outnum=c();to=c();from=c();innum=c();inoutid=c();inoutarrow=c();inoutdata=c()
  for(l in 1:length(MATRIX)){        #1~length(MATRIX)�����q���C�Ӥ��qIN�BOUT�����p
    outnum=which(CMATRIX[[l]][k,]>0) #�N����k���q��outdegree
    to=rep("out",length(outnum))
    innum=which(CMATRIX[[l]][,k]>0)  #�N����k���q��indegree
    from=rep("in",length(innum))
    inoutid=c(outnum,innum)          #�X��in�Boutdegree�����qid
    inoutarrow=c(to,from)            #�X��in�Boutdegree��V�����
    inoutdata=data.frame(rep(Date[[l]],length(inoutid)),inoutid,inoutarrow)
    colnames(inoutdata)= c("Date","ID",'Arrow')
    oneinout=rbind(oneinout,inoutdata)
  }
  Oneinout[[k]]=oneinout   #�N�@�����q�b�Ҧ��ɶ��I�����p(�ɶ��I�@length(MATRIX))�A�إ�dataframe�s�JOneinout�A�ҥHOneinout��length(ID)��dataframe
}
return(Oneinout)
}