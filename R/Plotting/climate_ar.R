par(mfrow=c(2,1),mar=c(1,1,0,1),oma=c(4,4,5,2),family="serif",bg="white")
climateSD <- 0.3
plot(1 + arima.sim(list(ar=climateAR),mean=0,n=100,sd=climateSD),
      xlim=c(0,100),
      ylim=c(-1,3),
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
#axis(side=1,col="grey")
abline(h=1,col="darkgrey",lty=2)

climateSD <- 0.5
plot(1 + arima.sim(list(ar=climateAR),mean=0,n=100,sd=climateSD),
      xlim=c(0,100),
      ylim=c(-1,3),
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
abline(h=1,col="darkgrey",lty=2)

topats <- seq(mean(c(0,1/3)),1,1/3)
rightats <- seq(mean(c(0,1/2)),1,1/2)
mtext("SD = 0.3",font=3,cex=0.75,outer=T,side=4,at=rightats[2],line=0)
mtext("SD = 0.5",font=3,cex=0.75,outer=T,side=4,at=rightats[1],line=0)
###
mtext("Ticks",font=2,outer=T,side=1,line=2)
mtext("Level",font=2,outer=T,side=2,line=2)
mtext("Environmental Time Series",font=2,outer=T,side=3,line=3)
###
dev.copy(png,file="../Images/environment_ts.png",height=800,width=1200,units="px",res=150)
dev.off()
