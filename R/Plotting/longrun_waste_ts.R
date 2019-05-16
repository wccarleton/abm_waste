par(mfcol=c(2,3),mar=c(1,1,0,1),oma=c(4,4,5,2),family="serif",bg="white")
for(j in c(1:6)){
   datadir <- paste("../Data/00",j,"/",sep="")
   dataobjects <- list.files(datadir)
   dataobjects <- dataobjects[grep("longrun",dataobjects)]
   load(paste(datadir,dataobjects,sep=""))
   plot(unlist(lapply(nl.env$pop_waste_prob,mean)),
         xlim=c(0,10000),
         ylim=c(0,1),
         xaxt="na",
         yaxt="na",
         main=NA,
         ylab=NA,
         xlab=NA,
         frame.plot=F,
         type="l",
         lty=1,
         col=rgb(0.2,0.2,0.2))
   axis(side=2,col="grey")
   axis(side=1,col="grey")
}

topats <- seq(mean(c(0,1/3)),1,1/3)
rightats <- seq(mean(c(0,1/2)),1,1/2)
mtext("Mature = 1",font=3,cex=0.75,outer=T,side=3,at=topats[1],line=1)
mtext("Mature = 5",font=3,cex=0.75,outer=T,side=3,at=topats[2],line=1)
mtext("Mature = 10",font=3,cex=0.75,outer=T,side=3,at=topats[3],line=1)
mtext("SD = 0.3",font=3,cex=0.75,outer=T,side=4,at=rightats[2],line=0)
mtext("SD = 0.5",font=3,cex=0.75,outer=T,side=4,at=rightats[1],line=0)
###
mtext("Ticks",font=2,outer=T,side=1,line=2)
mtext("Trait Value",font=2,outer=T,side=2,line=2)
mtext("Waste Prob. Long-Run Time Series",font=2,outer=T,side=3,line=3)
###
dev.copy(png,file="../Images/waste_longrun_ts.png",height=800,width=1200,units="px",res=150)
dev.off()
