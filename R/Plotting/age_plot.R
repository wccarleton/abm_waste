par(mfcol=c(2,3),mar=c(1,1,3,1),oma=c(4,4,5,2),family="serif",bg="white")
xlims <- c(100,50,300,100,400,125)
for(k in c(1:6)){
   hist(age_samples[[k]],
      #seq(0,1100,10),
      xaxt="n",
      yaxt="n",
      col=rgb(0.75,0.75,0.75),
      border="white",
      freq=F,
      #xlim=c(0,xlims[k]),
      main=paste("Experiment ",k,sep=""))
   age_mean <- round(mean(age_samples[[k]]),0)
   plot_coords <- par("usr")
   text(x=plot_coords[2]*0.9,
         y=plot_coords[4]*0.9,
         #pos=2,
         bquote(bar(x)~"="~.(age_mean)))
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
mtext("Ticks",font=2,outer=T,side=1,line=2)
mtext("Density",font=2,outer=T,side=2,line=2)
mtext("Age at Death",font=2,outer=T,side=3)

dev.copy(png,file="../Images/age_at_death.png",width=1500,height=1200,units="px",res=200)
dev.off()
