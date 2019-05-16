par(mfcol=c(4,3),mar=c(1,1,0,1),oma=c(4,4,5,2),family="serif",bg="white")
for(j in c(1:6)){
   #neutral trait ts
   matplot(neutral_m[[j]],
         xlim=c(0,2000),
         ylim=c(0,1),
         xaxt="na",
         yaxt="na",
         main=NA,
         ylab=NA,
         xlab=NA,
         frame.plot=F,
         type="l",
         lty=1,
         col=rgb(0.2,0.2,0.2,0.2))
   axis(side=2,col="grey")
   text(x=0,y=1,"Neutral",pos=4,xpd=NA)
   
   #waste trait ts
   matplot(waste_m[[j]],
         xlim=c(0,2000),
         ylim=c(0,1),
         xaxt="na",
         yaxt="na",
         main=NA,
         ylab=NA,
         xlab=NA,
         frame.plot=F,
         type="l",
         lty=1,
         col=rgb(0.2,0.2,0.2,0.2))
   text(x=0,y=1,"Waste", pos=4, xpd=NA)
   axis(side=2,col="grey")
   if(j %in% c(2,4,6)){
      axis(side=1,col="grey")
   }
   lines(apply(waste_m[[j]],1,median),col="white")
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
mtext("Waste Prob. vs Neutral Time Series",font=2,outer=T,side=3,line=3)
###
dev.copy(png,file="../Images/netural_waste_ts.png",height=1000,width=1200,units="px",res=150)
dev.off()
