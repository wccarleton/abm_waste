par(mfcol=c(2,3),mar=c(1,1,3,1),oma=c(4,4,5,2),family="serif",bg="white")
corners <- par("usr")
xlims <- c(0.2,0.2,0.2,0.2,0.4,0.4)
countit <- 0
nsimulations <- 6 * 300
for(j in 1:6){
   datadir <- paste("../Data/00",j,"/",sep="")
   dataobjects <- list.files(datadir)
   dataobjects <- dataobjects[grep("longrun",dataobjects)]
   waste_prob_sample <- c()
   for(k in dataobjects){
      countit <- countit + 1
      cat("\r",countit / nsimulations,"")
      #print(dataobjects[k])
      load(paste(datadir,k,sep=""))
      nruns <- length(nl.env$pop_waste_prob)
      if(nruns >= 1999){
         waste_prob_sample <- c(waste_prob_sample,unlist(nl.env$pop_waste_prob[1500:nruns]))
      }
   }
   hist(waste_prob_sample,
         breaks=seq(0,1,0.01),
         freq=F,
         ylim=c(0,90),
         xlim=c(0,xlims[j]),
         xlab="Waste Prob.",
         main=paste("Experiment ",j,sep=""),
         xaxt="na",
         yaxt="na",
         border="white",
         col=rgb(0.2,0.2,0.2))
   axis(1,
         col="grey",
         col.ticks="grey")
   axis(2,
         col="grey",
         col.ticks="grey")
   #waste_prob_fit <- fitdist(waste_prob_sample,
   #                           distr="halfnorm",
   #                           start=list(scale=1/0.01))
   #hnorm_scale <- waste_prob_fit$estimate
   #polygon(y=c(dhalfnorm(seq(0,0.3,0.001),scale=hnorm_scale),rep(0,301)),
   #         x=c(seq(0,0.3,0.001),rev(seq(0,0.3,0.001))),
   #         col=rgb(0,0,0.5,0.25),
   #         border=F)
   polygon(y=c(dhalfnorm(seq(0,0.3,0.001),scale=125),rep(0,301)),
            x=c(seq(0,0.3,0.001),rev(seq(0,0.3,0.001))),
            col=rgb(0.5,0.5,0.5,0.5),
            border=F)
   abline(v=0.008,col=rgb(0.5,0.5,0.5))
   abline(v=mean(waste_prob_sample),col=rgb(0.5,0.5,0.5),lty=2)
   #print(ks.test(x=waste_prob_sample,y="phalfnorm",hnorm_scale))
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
mtext("Density",font=2,outer=T,side=2,line=2)
mtext("Empirical vs. Minimum\nWaste Prob. Distributions",font=2,outer=T,side=3)
##
dev.copy(png,file="../Images/minimum_waste_distributions.png",height=1000,width=1200,units="px",res=150)
dev.off()
