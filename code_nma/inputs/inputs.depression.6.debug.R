
n.disconnected.nodes <- 6


max.samples <- 6 #Maximum number of disconnected networks simulated CHANGED FROM 4 to 6

output.folder <- "output" #Name of the folder containing the results
RData.folder <- "RData_files" #Name of the folder containing the saved objects

ref.trt <- 2

#MCMC parameters



n.chains <- 3 #Number of mcmc chains
n.samples <- 1500 #Number of mcmc iterations FROM 150000 to 1500
n.adapt <- 300 #Number of adaptive iterations (tuning) FROM 3000 to 300
thin <- 1 #Thinning factor
n.burnin <- 900 #Number of iterations in the burn-in period FROM 50000 to 900

#Function's name for data sampling

data.fct.name <- "prep.data.depression"
