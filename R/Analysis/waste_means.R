waste_m <- list()
dirs <- c("001/","002/","003/","004/","005/","006/")
m <- 0
countit <- 0
nsimulations <- 6 * 300
skipit <- 0
nticks <- 1999
for(k in dirs){
   datadir <- paste("../Data/",k,sep="")
   dataobjects <- list.files(datadir)
   dataobjects <- dataobjects[grep("longrun",dataobjects)]
   waste_means <- c()
   n <- length(dataobjects)
   for(j in 1:n){
      countit <- countit + 1
      cat("\r",countit / nsimulations,"")
      load(paste(datadir,dataobjects[j],sep=""))
      pop_waste_len <- length(nl.env$pop_waste_prob)
      #print(pop_waste_len)
      if(pop_waste_len >= nticks){
         pop_waste <- nl.env$pop_waste_prob[1:nticks]
         waste_mean <- unlist(lapply(pop_waste,mean))
         tryCatch( waste_means <- cbind(waste_means,waste_mean),
                  warning=function(warn){
                           cat("run number: ",j," ",length(waste_mean),"\n")
                           skipit <<- 1
                           }
                  )
         if(skipit){
            skipit <<- 0
            next
         }
      }
   }
   m <- m + 1
   waste_m[[m]] <- waste_means
}
