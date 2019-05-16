dirs <- c("001","002","003","004","005","006")
mature <- c(1,1,5,5,10,10)
m <- 0
age_samples <- list()
for(k in dirs){
   m <- m + 1
   age_sample <- c()
   datadir <- paste("../Data/",k,"/",sep="")
   dataobjects <- list.files(datadir)
   dataobjects <- dataobjects[grep("longrun",dataobjects)]
   for(j in dataobjects){
      load(paste(datadir,j,sep=""))
      agent_waste_fitness <- data.frame(age_at_death=nl.env$agent_age_at_death,
                                 birth_tick=nl.env$agent_birth_tick,
                                 waste_prob=nl.env$agent_waste_prob,
                                 neutral=nl.env$agent_neutral,
                                 adult_off=nl.env$agent_lifetime_adult_offspring)
      cohort <- which(agent_waste_fitness[,"age_at_death"] > mature[m] & agent_waste_fitness[,"birth_tick"] == 0)

      #before selection
      age <- agent_waste_fitness[cohort,"age_at_death"]

      age_sample <- c(age_sample,age)
   }
   age_samples[[m]] <- age_sample
   #save(age_sample,file=paste("../Results/","age_sample_",k,".RData",sep=""))
}
