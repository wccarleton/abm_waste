dirs <- c("001","002","003")#,"004","005","006")
for(k in dirs[1]){
   dsd_neutral_sample <- c()
   datadir <- paste("../Data/",k,"/",sep="")
   dataobjects <- list.files(datadir)
   dataobjects <- dataobjects[grep("neutral",dataobjects)]
   for(j in dataobjects){
      load(paste(datadir,j,sep=""))
      agent_waste_fitness <- data.frame(age_at_death=nl.env$agent_age_at_death,
                                 birth_tick=nl.env$agent_birth_tick,
                                 waste_prob=nl.env$agent_waste_prob,
                                 neutral=nl.env$agent_neutral,
                                 adult_off=nl.env$agent_lifetime_adult_offspring)
      before_selection <- which(agent_waste_fitness[,"age_at_death"] > 1 & agent_waste_fitness[,"birth_tick"] < 100)
      after_selection <- which(agent_waste_fitness[,"age_at_death"] > 1 & agent_waste_fitness[,"birth_tick"] > 2800)

      #before selection
      Z1a <- agent_waste_fitness[before_selection,"neutral"]
      W1a <- agent_waste_fitness[before_selection,"adult_off"]

      Z1b <- agent_waste_fitness[before_selection,"waste_prob"]
      W1b <- agent_waste_fitness[before_selection,"adult_off"]

      #after after_selection
      Z2a <- agent_waste_fitness[after_selection,"neutral"]
      W2a <- agent_waste_fitness[after_selection,"adult_off"]

      Z2b <- agent_waste_fitness[after_selection,"waste_prob"]
      W2b <- agent_waste_fitness[after_selection,"adult_off"]

      ecdf_Z1a <- ecdf(Z1a)
      ecdf_Z1b <- ecdf(Z1b)

      ecdf_Z2a <- ecdf(Z2a)
      ecdf_Z2b <- ecdf(Z2b)

      dsd_sample_a <- sum(abs(ecdf_Z2a(seq(0,1,0.01)) - ecdf_Z1a(seq(0,1,0.01)))) * 0.01
      dsd_sample_b <- sum(abs(ecdf_Z2b(seq(0,1,0.01)) - ecdf_Z1b(seq(0,1,0.01)))) * 0.01
      dsd_neutral_sample <- c(dsd_neutral_sample,dsd_sample_a,dsd_sample_b)
   }
   save(dsd_neutral_sample,file=paste("../Results/DSD/","dsd_neutral_sample_",k,".RData",sep=""))
}
