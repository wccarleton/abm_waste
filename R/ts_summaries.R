# This script takes the NetLogo output and compiles time-series summaries. Be sure that the NetLogo .R data objects are contained in their own, separate directory (e.g., "../Results/" below).
# Change the paths below before running this script.

dataobjects <- list.files("../Results/")
reps <- lapply(1:100,function(j)rep(j,500))
reps <- rep(reps,2)
burnin <- 501
seriesl <- 1000
tick <- c(burnin:seriesl)
headings <- c("experiment",
            "rep",
            "tick",
            "population",
            "waste_prob_e_mn",
            "waste_rate_e_mn",
            "repro_prob_e_mn",
            "age_at_death_e_mn",
            "age_e_mn",
            "lifetime_offspring_e_mn")
write.table(file="../Results/Analysis/Summary/ts_summary.csv",
            t(headings),
            col.names=F,
            row.names=F,
            sep=",")
##
for(j in 1:length(reps){
   print(j)
   load(paste("../Results/",dataobjects[j],sep=""))
   expname <- nl.env$expname
   expname <- rep(expname,length(tick))

   population <- nl.env$reporter_population[burnin:seriesl]

   #print("WASTE")
   x <- nl.env$reporter_waste_prob[burnin:seriesl]
   x <- lapply(x,function(q){
                           q[which(q==0)]<-1e-07
                           q[which(q==1)]<-1 - 1e-07
                           return(q)
                           })
   x <- do.call(cbind.na,x)
   waste_prob_e_mn <- apply(x,2,function(a){
                                       tryCatch(MLEBetaExp(a),
                                                error=function(e)return(NA))
                                       })

   #print("WASTE2")
   x <- nl.env$reporter_waste_rate[burnin:seriesl]
   x <- lapply(x,function(q){
                           q[which(q==0)]<-1e-07
                           q[which(q==1)]<-1 - 1e-07
                           return(q)
                           })
   x <- do.call(cbind.na,x)
   waste_rate_e_mn <- apply(x,2,function(a){
                                       tryCatch(MLEBetaExp(a),
                                                error=function(e)return(NA))
                                       })

   #print("REPRO")
   x <- nl.env$reporter_repro_prob[burnin:seriesl]
   x <- lapply(x,function(q){
                           q[which(q==0)]<-1e-07
                           q[which(q==1)]<-1 - 1e-07
                           return(q)
                           })
   x <- do.call(cbind.na,x)
   repro_prob_e_mn <- apply(x,2,function(a){
                                       tryCatch(MLEBetaExp(a),
                                                error=function(e)return(NA))
                                       })

   #print("AGEDEATH")
   x <- nl.env$reporter_age_at_death[burnin:seriesl]
   x <- do.call(cbind.na,x)
   age_at_death_e_mn <- apply(x,2,function(a){
                                       tryCatch(MLEPoisExp(a),
                                                error=function(e)return(NA))
                                       })

   #print("AGE")
   x <- nl.env$reporter_age[burnin:seriesl]
   x <- do.call(cbind.na,x)
   age_e_mn <- apply(x,2,function(a){
                                       tryCatch(MLEPoisExp(a),
                                                error=function(e)return(NA))
                                       })

   #print("OFFS")
   x <- nl.env$reporter_lifetime_offspring[burnin:seriesl]
   x <- do.call(cbind.na,x)
   lifetime_offspring <- apply(x,2,function(a){
                                       tryCatch(MLEPoisExp(a),
                                                error=function(e)return(NA))
                                       })

   ts_summary <- cbind(expname,
                     reps[[j]],
                     tick,
                     population,
                     waste_prob_e_mn,
                     waste_rate_e_mn,
                     repro_prob_e_mn,
                     age_at_death_e_mn,
                     age_e_mn,
                     lifetime_offspring)

   write.table(file="../Results/Analysis/Summary/ts_summary.csv",
               ts_summary,
               col.names=F,
               row.names=F,
               append=T,
               sep=",")
}
