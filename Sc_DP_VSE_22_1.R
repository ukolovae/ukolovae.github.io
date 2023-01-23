
install.packages("ggplot2")
library("ggplot2")

#Path
setwd("G:/Můj disk/DP/zbytek/B/memory/R věci/Nets_by_age_F_2018/")

#Libraries
library(igraph)
library(Hmisc)

#Import data
path="G:/Můj disk/DP/zbytek/B/memory/R věci/Nets_by_age_F_2018/Node_met80_101"
met80_101<- read.csv(file = path)
head(met80_101)

#Uprava dat
log_met80_101 <- log(met80_101[,2:8])
met80_101=cbind(met80_101, log_met80_101)

#Jednodimenzionalni exploracni analyza
hist.data.frame(log_met80_101)
boxplot(log_met80_101)
popisne=summary(log_met80_101)

#Outliers (horni a dolni decil u vsech metrik)
log_met80_101$deg_outl=ifelse(log_met80_101$deg>quantile(log_met80_101$deg, probs=0.90, na.rm=T)|
                         log_met80_101$deg<quantile(log_met80_101$deg, probs=0.10, na.rm=T), log_met80_101$deg, "")
log_met80_101$bet_outl=ifelse(log_met80_101$bet>quantile(log_met80_101$bet, probs=0.90, na.rm=T)|
                              log_met80_101$bet<quantile(log_met80_101$bet, probs=0.10, na.rm=T), log_met80_101$bet, "")
log_met80_101$clos_outl=ifelse(log_met80_101$clos>quantile(log_met80_101$clos, probs=0.90, na.rm=T)|
                              log_met80_101$clos<quantile(log_met80_101$clos, probs=0.10, na.rm=T), log_met80_101$clos, "")
log_met80_101$eig_outl=ifelse(log_met80_101$eig>quantile(log_met80_101$eig, probs=0.90, na.rm=T)|
                              log_met80_101$eig<quantile(log_met80_101$eig, probs=0.10, na.rm=T), log_met80_101$eig, "")
log_met80_101$as_outl=ifelse(log_met80_101$as>quantile(log_met80_101$as, probs=0.90, na.rm=T)|
                              log_met80_101$as<quantile(log_met80_101$as, probs=0.10, na.rm=T), log_met80_101$as, "")
log_met80_101$pr_outl=ifelse(log_met80_101$pr>quantile(log_met80_101$pr, probs=0.90, na.rm=T)|
                              log_met80_101$pr<quantile(log_met80_101$pr, probs=0.10, na.rm=T), log_met80_101$pr, "")
log_met80_101$harm_cent_outl=ifelse(log_met80_101$harm_cent>quantile(log_met80_101$harm_cent, probs=0.90, na.rm=T)|
                              log_met80_101$harm_cent<quantile(log_met80_101$harm_cent, probs=0.10, na.rm=T), log_met80_101$harm_cent, "")

#Soubor s hodnotami u outliers
met_outl=cbind(substr(met80_101$names,3,5), log_met80_101$deg_outl, log_met80_101$bet_outl, log_met80_101$clos_outl,
               log_met80_101$eig_outl, log_met80_101$as_outl,
               log_met80_101$pr_outl, log_met80_101$harm_cent_outl)
colnames(met_outl) <- c("names", "deg", "bet", "clos", "eig", "as", "pr", "harm_cent") 


#Zavislosti vsech metrik
plot(log_met80_101, pch=20 , cex=1.5 , col="#69b3a2")
cormat=cor(log_met80_101, method = c("spearman"))

#Zavislosti vsech metrik bez outlieru
log_met80_101$outl=ifelse(log_met80_101[,9]!=""|log_met80_101[,10]!=""|
                        log_met80_101[,11]!=""| log_met80_101[,11]!=""|
                        log_met80_101[,12]!=""|log_met80_101[,13]!=""| log_met80_101[,14]!="", "outl", "nooutl")
nooutl=log_met80_101[log_met80_101$outl != "outl", ]      
plot(nooutl[,1:7], pch=20 , cex=1.5 , col="#69b3a2")


see=cbind(substr(met80_101$names,3,5), log_met80_101[,1:7], log_met80_101[,16])
colnames(see) <- c("names", "deg", "bet", "clos", "eig", "as", "pr", "harm_cent", "outl") 

#Zavislosti: barva podle kapitoly
nooutl=see[see$outl != "outl", ] 
nooutl$kapitola=substr(nooutl$names,1,1)
ggplot(nooutl, aes(x=deg, y=bet, color=kapitola, size=12)) + geom_point()
ggplot(nooutl, aes(x=deg, y=clos, color=kapitola, size=12)) + geom_point()
ggplot(nooutl, aes(x=deg, y=eig, color=kapitola, size=12)) + geom_point()
ggplot(nooutl, aes(x=deg, y=as, color=kapitola, size=12)) + geom_point()
ggplot(nooutl, aes(x=deg, y=pr, color=kapitola, size=12)) + geom_point()
ggplot(nooutl, aes(x=deg, y=harm_cent, color=kapitola, size=12)) + geom_point()

ggplot(nooutl, aes(x=bet, y=clos, color=kapitola, size=12)) + geom_point()
ggplot(nooutl, aes(x=bet, y=eig, color=kapitola, size=12)) + geom_point()
ggplot(nooutl, aes(x=bet, y=as, color=kapitola, size=12)) + geom_point()
ggplot(nooutl, aes(x=bet, y=pr, color=kapitola, size=12)) + geom_point()
ggplot(nooutl, aes(x=bet, y=harm_cent, color=kapitola, size=12)) + geom_point()

ggplot(nooutl, aes(x=clos, y=eig, color=kapitola, size=12)) + geom_point()
ggplot(nooutl, aes(x=clos, y=as, color=kapitola, size=12)) + geom_point()
ggplot(nooutl, aes(x=clos, y=pr, color=kapitola, size=12)) + geom_point()
ggplot(nooutl, aes(x=clos, y=harm_cent, color=kapitola, size=12)) + geom_point()

ggplot(nooutl, aes(x=eig, y=as, color=kapitola, size=12)) + geom_point()
ggplot(nooutl, aes(x=eig, y=pr, color=kapitola, size=12)) + geom_point()
ggplot(nooutl, aes(x=eig, y=harm_cent, color=kapitola, size=12)) + geom_point()

ggplot(nooutl, aes(x=as, y=pr, color=kapitola, size=12)) + geom_point()
ggplot(nooutl, aes(x=as, y=harm_cent, color=kapitola, size=12)) + geom_point()

ggplot(nooutl, aes(x=pr, y=harm_cent, color=kapitola, size=12)) + geom_point()



#Prumery globalnich ukazatelu
avg_names=c("deg", "bet", "clos", "eig", "pr", "harm_cent") 
avg_deg=cbind(mean(met0_20$deg), mean(met20_35$deg), mean(met35_50$deg), mean(met50_65$deg), mean(met65_80$deg), mean(met80_101$deg))
avg_bet=cbind(mean(met0_20$bet), mean(met20_35$bet), mean(met35_50$bet), mean(met50_65$bet), mean(met65_80$bet), mean(met80_101$bet))
avg_clos=cbind(mean(met0_20$clos, na.rm=TRUE), mean(met20_35$clos, na.rm=TRUE), mean(met35_50$clos, na.rm=TRUE), mean(met50_65$clos, na.rm=TRUE), mean(met65_80$clos, na.rm=TRUE), mean(met80_101$clos, na.rm=TRUE))
avg_eig=cbind(mean(met0_20$eig), mean(met20_35$eig), mean(met35_50$eig), mean(met50_65$eig), mean(met65_80$eig), mean(met80_101$eig))
avg_pr=cbind(mean(met0_20$pr), mean(met20_35$pr), mean(met35_50$pr), mean(met50_65$pr), mean(met65_80$pr), mean(met80_101$pr))
avg_harm_cent=cbind(mean(met0_20$harm_cent), mean(met20_35$harm_cent), mean(met35_50$harm_cent), mean(met50_65$harm_cent), mean(met65_80$harm_cent), mean(met80_101$harm_cent))

global_stats=rbind( avg_deg, avg_bet, avg_clos, avg_eig, avg_pr, avg_harm_cent)

par(mfrow = c(2, 3))
plot(global_stats[1,], type="l", main="Degree")
plot(global_stats[2,], type="l", main="Betweenness")
plot(global_stats[3,], type="l", main="Closeness")
plot(global_stats[4,], type="l", main="Eigenvector (AS)")
plot(global_stats[5,], type="l", main="Page rank")
plot(global_stats[6,], type="l", main="Harm. centrality")

#Mediany globalnich ukazatelu
med_names=c("deg", "bet", "clos", "eig", "pr", "harm_cent") 
med_deg=cbind(median(met0_20$deg), median(met20_35$deg), median(met35_50$deg), median(met50_65$deg), median(met65_80$deg), median(met80_101$deg))
med_bet=cbind(median(met0_20$bet), median(met20_35$bet), median(met35_50$bet), median(met50_65$bet), median(met65_80$bet), median(met80_101$bet))
med_clos=cbind(median(met0_20$clos, na.rm=TRUE), median(met20_35$clos, na.rm=TRUE), median(met35_50$clos, na.rm=TRUE), median(met50_65$clos, na.rm=TRUE), median(met65_80$clos, na.rm=TRUE), median(met80_101$clos, na.rm=TRUE))
med_eig=cbind(median(met0_20$eig), median(met20_35$eig), median(met35_50$eig), median(met50_65$eig), median(met65_80$eig), median(met80_101$eig))
med_pr=cbind(median(met0_20$pr), median(met20_35$pr), median(met35_50$pr), median(met50_65$pr), median(met65_80$pr), median(met80_101$pr))
med_harm_cent=cbind(median(met0_20$harm_cent), median(met20_35$harm_cent), median(met35_50$harm_cent), median(met50_65$harm_cent), median(met65_80$harm_cent), median(met80_101$harm_cent))

global_stats=rbind( med_deg, med_bet, med_clos, med_eig, med_pr, med_harm_cent)

par(mfrow = c(2, 3))
plot(global_stats[1,], type="l", main="Degree")
plot(global_stats[2,], type="l", main="Betweenness")
plot(global_stats[3,], type="l", main="Closeness")
plot(global_stats[4,], type="l", main="Eigenvector (AS)")
plot(global_stats[5,], type="l", main="Page rank")
plot(global_stats[6,], type="l", main="Harm. centrality")

#Zkoumani vah hran
#Import data
path="G:/Můj disk/DP/zbytek/B/memory/R věci/Nets_by_age_F_2018/Elist80_101"
e80_101<- read.csv(file = path)
head(e80_101)
hist(e80_101$weight)

quantile(e80_101$weight, p=c(0.10, 0.25, 0.50, 0.75, 0.90))
e80_101filtr=e80_101[e80_101$weight>quantile(e80_101$weight, 0.75) & e80_101$weight<quantile(e80_101$weight, 0.99),]
hist(log(e80_101filtr$weight))
top1pct80_101=e80_101[e80_101$weight>quantile(e80_101$weight, 0.99),]
ntop80_101=as.numeric(nrow(top1pct80_101))

top=rbind(ntop0_20, ntop20_35, ntop35_50, ntop50_65, ntop65_80, ntop80_101)
plot(top, type="l")

#Pocety v dolnim medianu
plot(rbind(nrow(e0_20[e0_20$weight<quantile(e0_20$weight, 0.50),]),
      nrow(e20_35[e20_35$weight<quantile(e20_35$weight, 0.50),]),
      nrow(e35_50[e35_50$weight<quantile(e35_50$weight, 0.50),]),
      nrow(e50_65[e50_65$weight<quantile(e50_65$weight, 0.50),]),
      nrow(e80_101[e80_101$weight<quantile(e80_101$weight, 0.50),])), type="l")
      
#Pocety v dolnim kvantilu
plot(rbind(nrow(e0_20[e0_20$weight<quantile(e0_20$weight, 0.75),]),
           nrow(e20_35[e20_35$weight<quantile(e20_35$weight, 0.75),]),
           nrow(e35_50[e35_50$weight<quantile(e35_50$weight, 0.75),]),
           nrow(e50_65[e50_65$weight<quantile(e50_65$weight, 0.75),]),
           nrow(e80_101[e80_101$weight<quantile(e80_101$weight, 0.75),])), type="l")

#Pocety v 50% prostředku
plot(rbind(nrow(e0_20[e0_20$weight<quantile(e0_20$weight, 0.75) & e0_20$weight>quantile(e0_20$weight, 0.25),]),
           nrow(e20_35[e20_35$weight<quantile(e20_35$weight, 0.75) & e20_35$weight>quantile(e20_35$weight, 0.25),]),
           nrow(e35_50[e35_50$weight<quantile(e35_50$weight, 0.75) & e35_50$weight>quantile(e35_50$weight, 0.25),]),
           nrow(e50_65[e50_65$weight<quantile(e50_65$weight, 0.75) & e50_65$weight>quantile(e50_65$weight, 0.25),]),
           nrow(e80_101[e80_101$weight<quantile(e80_101$weight, 0.75) & e80_101$weight>quantile(e80_101$weight, 0.25),])), type="l")

























