# These functiosn depend on the R pacakge fitdistrplus (https://cran.r-project.org/web/packages/fitdistrplus/index.html)

MLEBetaExp <- function(x){
   beta_fit <- fitdist(x[which(!is.na(x))],"beta",method="mle")
   beta_exp <- beta_fit$estimate[1] / (beta_fit$estimate[1] + beta_fit$estimate[2])
   names(beta_exp) <- "expectation"
   return(beta_exp)
}

MLEPoisExp <- function(x){
   pois_fit <- fitdist(x[which(!is.na(x))],"pois",method="mle")
   pois_exp <- pois_fit$estimate[1]
   names(pois_exp) <- "expectation"
   return(pois_exp)
}

MLENormExp <- function(x){
   norm_fit <- fitdist(x[which(!is.na(x))],"norm",method="mle")
   norm_exp <- norm_fit$estimate[1]
   names(norm_exp) <- "expectation"
   return(norm_exp)
}

MLENormParams <- function(x){
   norm_fit <- fitdist(x[which(!is.na(x))],"norm",method="mle")
   norm_params <- norm_fit$estimate
   names(norm_params) <- c("expectation","sd")
   return(norm_params)
}
