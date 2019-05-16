par(mfcol=c(2,3),mar=c(1,1,3,1),oma=c(4,4,5,2),family="serif",bg="white")
datadir <- "../Results/DSD/"
dataobjects <- list.files(datadir)
for(k in c(1:6)){
   load(paste("../Results/DSD/","dsd_neutral_sample_00",k,".RData",sep=""))
   load(paste("../Results/DSD/","dsd_waste_sample_00",k,".RData",sep=""))
   hist(dsd_neutral_sample,
      breaks=seq(0,1,0.01),
      xaxt="n",
      yaxt="n",
      col=rgb(0.75,0.75,0.75),
      border="white",
      freq=F,
      xlim=c(0,0.25),
      main=paste("Experiment ",k,sep=""))
   hist(dsd_waste_sample,
      breaks=seq(0,1,0.01),
      xaxt="n",
      yaxt="n",
      col=rgb(0.25,0.25,0.25),
      border="white",
      freq=F,
      xlim=c(0,0.25),
      main=paste("Experiment ",k,sep=""),
      add=T)
   axis(1,col="grey")
   axis(2,col="grey")
}

topats <- seq(mean(c(0,1/3)),1,1/3)
rightats <- seq(mean(c(0,1/2)),1,1/2)
mtext("Mature = 1",font=3,cex=0.75,outer=T,side=3,at=topats[1],line=-1)
mtext("Mature = 5",font=3,cex=0.75,outer=T,side=3,at=topats[2],line=-1)
mtext("Mature = 10",font=3,cex=0.75,outer=T,side=3,at=topats[3],line=-1)
mtext("SD = 0.3",font=3,cex=0.75,outer=T,side=4,at=rightats[2],line=0)
mtext("SD = 0.5",font=3,cex=0.75,outer=T,side=4,at=rightats[1],line=0)
###
mtext("DSD",font=2,outer=T,side=1,line=2)
mtext("Density",font=2,outer=T,side=2,line=2)
mtext("DSD Distributions",font=2,outer=T,side=3)

dev.copy(png,file="../Images/dsd_neutral_waste.png",width=1500,height=1200,units="px",res=200)
dev.off()
