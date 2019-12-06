prep.data.simulated <- function(){
  
  library(mgcv)
  library(boot)
  
  n.treatments <- 4
  n.studies <- 5
  B <- 1 # The baseline treatment across all studies
  alpha.mn.1 <- -0.4
  alpha.mn.2 <- 0.4
  alpha.sd <- 0.5 # for variance of 0.25
  sample.size <- 2000
  
  d <- rep(0.5, n.treatments)
  alphas <- c(rnorm(n.studies / 2, alpha.mn.1, alpha.sd ^ 2), rnorm(n.studies - (n.studies / 2), alpha.mn.2, alpha.sd ^ 2))
  hist(alphas)
  sigma <- 0.5
  rho <- 0.5
  
  cov.matrix <- matrix(data = 0, nrow = n.treatments, ncol = n.treatments)
  for (row in 1:nrow(cov.matrix)) {
    for (col in 1:ncol(cov.matrix)) {
      if (row == col) {
        cov.matrix[row, col] <- rho * sigma
      } else {
        cov.matrix[row, col] <- sigma
      }
    }
  }
  
  # row i represemts the vector of contrasts for study i!!
  deltas <- rmvn(n.studies, d, cov.matrix)
  for (row in 1:nrow(deltas)) {
    deltas[row, B] <- 0
  }
  cat("deltas")
  deltas
  
  p <- matrix(data = 0, nrow = n.studies, ncol = n.treatments)
  for (row in 1:nrow(p)) {
    for (col in 1:ncol(p)) {
      p[row, col] <- inv.logit(deltas[row, col] + alphas[row])
    }
  }
  
  r <- matrix(data = 0, nrow = n.studies, ncol = n.treatments)
  for (row in 1:nrow(r)) {
    for (col in 1:ncol(r)) {
      r[row, col] <- rbinom(1, sample.size, p[row, col])
    }
  }
  
  responders <- as.vector(r)
  sampleSize <- rep(sample.size, n.studies * n.treatments)
  studyNumber <- rep(0, n.studies * n.treatments)
  treatmentNumber <- rep(0, n.studies * n.treatments)
  
  for (study in 1:n.studies) {
    for (treatment in 1:n.treatments) {
      studyNumber[(study - 1) * n.treatments + treatment] <- study
      treatmentNumber[(study - 1) * n.treatments + treatment] <- treatment
    }
  }
  
  sim.data <- data.frame(studyNumber, treatmentNumber, responders, sampleSize)
  
  
  
  trt.names <- sim.data$treatmentNumber
  trt.numbers <- 1:length(trt.names)
  
  study.names <- unique(sim.data$studyNumber)
  study.numbers <- 1:length(study.names)
  
  trt.names.data.frame <- data.frame(cbind(trt.numbers, trt.names))
  
  sim.data$t.id <- as.numeric(as.character(mapvalues(sim.data$treatmentNumber,
                                                            trt.names, 
                                                            trt.numbers)))
  
  sim.data$s.id <- as.numeric(as.character(mapvalues(sim.data$studyNumber,
                                                            study.names, 
                                                            study.numbers)))
  
  
  sim.data <- rename(sim.data, c("responders"="r", "sampleSize"="n"))
  
  
  ##### TO ATTEMPT 2 ARMS SITCH
  
  n.arms <- table(sim.data$s.id)
  
  which.2.arms <- as.numeric(names(which(n.arms == 2)))
  
  sim.2.arms.only <- sim.data[which(sim.data$s.id %in% which.2.arms),]
  
  
  
  
  
  
  plot.network(paste0(output.folder,"/plots/raw_data_network.pdf"), 
               sim.data, 
               "", 
               trt.names.data.frame)
  
  write.treatment.description(paste0(output.folder,"/treatment-description.txt"),
                              trt.names.data.frame,
                              ref.trt)
  
  return(list("data"=sim.data, "treatments"=trt.names.data.frame))
  
}
