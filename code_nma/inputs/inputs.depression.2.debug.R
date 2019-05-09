#Name of the function that gets and prepares the dataset
data.fct.name <- "prep.data.depression"

n.disconnected.nodes <- 2
max.samples <- 4
output.folder <- "output"
RData.folder <- "RData_files"
ref.trt <- 2

#MCMC parameters
## I DECREASED THE NUMBER OF  ZEROS
n.chains <- 3
n.samples <- 1500
n.adapt <- 3000
thin <- 1
n.burnin <- 500


