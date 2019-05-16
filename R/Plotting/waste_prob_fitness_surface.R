par(mfcol=c(2,3),mar=c(1,1,3,1),oma=c(4,4,5,2),family="serif",bg="white")
m <- 0
mature <- c(1,1,5,5,10,10)
for(j in 1:6){
   m <- m + 1
   datadir <- paste("../Data/00",j,"/",sep="")
   dataobjects <- list.files(datadir)
   dataobjects <- dataobjects[grep("longrun",dataobjects)]
   load(paste(datadir,dataobjects[sample(1:300,1)],sep=""))
   adults <- which(nl.env$agent_age_at_death > mature[m])
   W_adults <- nl.env$agent_lifetime_adult_offspring[adults]
   WP_adults <- nl.env$agent_waste_prob[adults]
   plot(y=W_adults,
         x=WP_adults,
         pch=20,
         col=rgb(0.5,0.5,0.5,0.5),
         xaxt="na",
         yaxt="na",
         main=paste("Experiment ",m,sep=""),
         ylab=NA,
         xlab=NA,
         frame.plot=F,
         ylim=c(0,6))
   axis(1,col="grey")
   axis(2,at=seq(0,10,1),col="grey")
}

topats <- seq(mean(c(0,1/3)),1,1/3)
rightats <- seq(mean(c(0,1/2)),1,1/2)
mtext("Mature = 1",font=3,cex=0.75,outer=T,side=3,at=topats[1],line=-1)
mtext("Mature = 5",font=3,cex=0.75,outer=T,side=3,at=topats[2],line=-1)
mtext("Mature = 10",font=3,cex=0.75,outer=T,side=3,at=topats[3],line=-1)
mtext("SD = 0.2",font=3,cex=0.75,outer=T,side=4,at=rightats[2],line=0)
mtext("SD = 0.3",font=3,cex=0.75,outer=T,side=4,at=rightats[1],line=0)
###
mtext("Waste Prob.",font=2,outer=T,side=1,line=2)
mtext("N. Adult Offspring",font=2,outer=T,side=2,line=2)
mtext("Waste Prob. Selection",font=2,outer=T,side=3)

dev.copy(png,file="../Images/waste_prob_selection.png",width=1500,height=1200,units="px",res=200)
dev.off()
