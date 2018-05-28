# We looked at each Climate SD level separately because our primary aim was to test a specific prediction of Dunnell's waste hypothesis.

pt_waste_prob_mean_sd1 <- pairwise.t.test(subset(waste_prob_params_df,ClimateCondition=="1")[,"waste_pr.expectation"],
                                       subset(waste_prob_params_df,ClimateCondition=="1")[,"WasteCondition"],
                                       p.adjust="bonferroni",
                                       alternative="less",
                                       pool.sd=F)
#
pt_waste_prob_mean_sd3 <- pairwise.t.test(subset(waste_prob_params_df,ClimateCondition=="3")[,"waste_pr.expectation"],
                                       subset(waste_prob_params_df,ClimateCondition=="3")[,"WasteCondition"],
                                       p.adjust="bonferroni",
                                       alternative="less",
                                       pool.sd=F)
#
pt_waste_prob_mean_sd5 <- pairwise.t.test(subset(waste_prob_params_df,ClimateCondition=="5")[,"waste_pr.expectation"],
                                       subset(waste_prob_params_df,ClimateCondition=="5")[,"WasteCondition"],
                                       p.adjust="bonferroni",
                                       alternative="less",
                                       pool.sd=F)

#export results
pt_pvals <- data.frame(comparison=c("n-w","n-wo","w-w","w-wo"),
                  "SD1"=as.vector(pt_waste_prob_mean_sd1$p.value),
                  "SD3"=as.vector(pt_waste_prob_mean_sd3$p.value),
                  "SD5"=as.vector(pt_waste_prob_mean_sd5$p.value))
pt_pvals <- pt_pvals[-3,]

# Change this path, of course, before running this script.

write.table(pt_pvals,file="../Results/Analysis/TTests/pt_pvals_waste_prob_means.csv",sep=",")

#get mean diffs
waste_combns <- combn(c("N","W","WO"),2)
diff_ints <- matrix(NA,ncol=2,nrow=1)
for(j in c(1,3,5)){
   temp <- apply(waste_combns,2,function(x,j,a){
      diff_int <- as.vector(t.test(a[which(a[,"ClimateCondition"]==j & a[,"WasteCondition"]==x[1]),"waste_pr.expectation"],
                                    a[which(a[,"ClimateCondition"]==j & a[,"WasteCondition"]==x[2]),"waste_pr.expectation"],
                                    alternative="greater")$conf.int)
      return(diff_int)
   },j=j,a=waste_prob_params_df)
   diff_ints <- rbind(diff_ints,t(temp))
}

diff_ints <- data.frame(c(1,1,1,3,3,3,5,5,5),matrix(rep(waste_combns,3),ncol=2,byrow=T),diff_ints[-1,])
names(diff_ints) <- c("Climate","X","Y","diff_lo","diff_hi")

# Change this path, of course, before running this script.

write.table(diff_ints,file="../Results/Analysis/TTests/diff_ints_waste_prob_means.csv",sep=",")
