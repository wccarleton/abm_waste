neutral_m <- list()
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
   neutral_means <- c()
   n <- length(dataobjects)
   for(j in 1:n){
      countit <- countit + 1
      cat(countit / nsimulations,"\r")
      load(paste(datadir,dataobjects[j],sep=""))
      pop_neutral_len <- length(nl.env$pop_neutral)
      #print(pop_neutral_len)
      if(pop_neutral_len >= nticks){
         pop_neutral <- nl.env$pop_neutral[1:nticks]
         neutral_mean <- unlist(lapply(pop_neutral,mean))
         tryCatch( neutral_means <- cbind(neutral_means,neutral_mean),
                  warning=function(warn){
                           cat("run number: ",j," ",length(neutral_mean),"\n")
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
   neutral_m[[m]] <- neutral_means
}
