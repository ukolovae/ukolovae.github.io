
#Age groups: 0_20 20_35 35_50 50_65 65_80 80_101



#Path
setwd("G:/Můj disk/DP/zbytek/B/memory/R věci/Nets_by_age_F_2018/")

#Libraries
library(igraph)

#Import data
path="G:/Můj disk/DP/zbytek/B/memory/R věci/Nets_by_age_F_2018/Mat80_101.csv"

my_data <- read.csv(file = path)
elist.name="Elist80_101"
nlist.name="Nlist80_101"
cent.name.name="Node_met80_101"

  
#Create adjacency matrix for unimodal graph (mat.AAt)
  df = subset(my_data, select = -c(id) )
  mat.A=as.matrix(df)
  mat.At=t(mat.A)
  mat.AAt=mat.At%*%mat.A
#Erase memory
  rm(mat.A, mat.At, my_data, df)
#Create graph
  mat.AAt.no.dg=mat.AAt #Put away diagonal (total number of neighbours)
  diag(mat.AAt.no.dg)=0
  g.name <- graph_from_adjacency_matrix(mat.AAt.no.dg, weighted = T)
#Graph centrality measures
  names=V(g.name)$name
  deg=degree(g.name)
  bet=betweenness(g.name)
  clos=closeness(g.name)
  eig=eigen_centrality(g.name)$vector
  as=authority_score(g.name)$vector
  pr=page_rank(g.name)$vector
  harm_cent=harmonic_centrality(g.name)
  cent.name=data.frame(names, deg, bet, clos, eig, as, pr, harm_cent)
#Prepare raw edge list
  elist=get.data.frame(g.name)
  elist<-subset(elist, elist$from!=elist$to)
  elist$from=substr(elist$from,3,5)
  elist$to=substr(elist$to,3,5)
#Prepare node list for import to Gephi
  nlist=V(g.name)$name
  nlist=as.data.frame(nlist)
  names(nlist)[1]="Label"
  nlist$Label=substr(nlist$Label,3,5)
  nlist=tibble::rownames_to_column(nlist, "ID")
  nlist$to=nlist$from=nlist$Label
#Complete the edge list (assign from the node list ids of nodes)
  elist_fin1<- merge(x=elist, y = nlist[ , c("ID", "from")], by="from")
  elist_fin1$ID.from=elist_fin1$ID
  elist_fin2<- merge(x=elist_fin1, y = nlist[ , c("ID", "to")], by="to")
  elist_fin2$ID.to=elist_fin2$ID
  names(elist_fin2)[1]="Label_to"
  names(elist_fin2)[2]="Label_from"
  names(elist_fin2)[4]="Source"
  names(elist_fin2)[6]="Target"
  elist.export=elist_fin2[,c(4, 6, 3, 2, 1)]
  elist.export$from=as.numeric(elist.export$Source)
  elist.export$to=as.numeric(elist.export$Target)
#Write csv of node list and edge list
  write.csv(elist.export, file = elist.name, row.names=F)
  write.csv(nlist, file = nlist.name,  row.names=F)
  write.csv(cent.name, file=cent.name.name, row.names=F)










