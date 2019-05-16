par(mfcol=c(2,3),mar=c(1,1,3,1),oma=c(4,4,5,2),family="serif",bg="white")
datadir <- "../Results/SelectDiff/"
dataobjects <- list.files(datadir)
for(k in c(1:6)){
   load(paste(datadir,"s_neutral_sample_00",k,".RData",sep=""))
   load(paste(datadir,"s_waste_sample_00",k,".RData",sep=""))
   hist(s_waste_sample,
      breaks=seq(-0.6,0.6,0.01),
      xaxt="n",
      yaxt="n",
      col=rgb(0.25,0.25,0.25),
      border="white",
      freq=F,
      xlim=c(-.25,.1),
      main=paste("Experiment ",k,sep=""))
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
mtext("Selection Differential",font=2,outer=T,side=1,line=2)
mtext("Density",font=2,outer=T,side=2,line=2)
mtext("Selection Differential Distributions",font=2,outer=T,side=3)

dev.copy(png,file="../Images/sdiff_waste.png",width=1500,height=1200,units="px",res=200)
dev.off()
