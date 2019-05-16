dirs <- c("001","002","003","004","005","006")
mature <- c(1,1,5,5,10,10)
m <- 0
countit <- 0
nsimulations <- 6 * 300
for(k in dirs){
   m <- m + 1
   s_waste_sample <- c()
   s_neutral_sample <- c()
   datadir <- paste("../Data/",k,"/",sep="")
   dataobjects <- list.files(datadir)
   dataobjects <- dataobjects[grep("longrun",dataobjects)]
   for(j in dataobjects){
      countit <- countit + 1
      cat("\r",countit / nsimulations,"")
      load(paste(datadir,j,sep=""))
      agent_waste_fitness <- data.frame(age_at_death=nl.env$agent_age_at_death,
                                 birth_tick=nl.env$agent_birth_tick,
                                 waste_prob=nl.env$agent_waste_prob,
                                 neutral=nl.env$agent_neutral,
                                 adult_off=nl.env$agent_lifetime_adult_offspring)
      cohort <- which(agent_waste_fitness[,"age_at_death"] > mature[m] & agent_waste_fitness[,"birth_tick"] == 0)

      #before selection
      Z_waste <- matrix(agent_waste_fitness[cohort,"waste_prob"],ncol=1)
      W <- agent_waste_fitness[cohort,"adult_off"]

      if(all(W == 0)){
         print(paste("skipping",k,"/",j,sep=""))
         next
      }

      s_waste <- analyze.selection(Z_waste,W)

      s_waste_sample <- c(s_waste_sample,s_waste[[5]])
   }
   save(s_waste_sample,file=paste("../Results/SelectDiff/","s_waste_sample_",k,".RData",sep=""))
}
