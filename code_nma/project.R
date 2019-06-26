## ALTERNATE DATASETS
install.packages("gemtc")


#
rm(list = ls())
library(stringr)

measure_of_success <- 0
dsname <- readline(prompt = "Dataset: \n")
modelname <- readline(prompt = "Model for RBE: \n")
params <- readline(prompt = "Parameters for above model: \n")
plot_mos <- as.logical((readline(prompt = "Done comparing analyses? (TRUE or FALSE) \n"))[1])

###Get inputs and header###
source(paste0("code_nma/inputs/inputs.general.R"), 
       local=FALSE, 
       chdir=TRUE)
input.variables <- ls()

######output.folder hereeee
source("code_nma/header.R", 
       local=FALSE, 
       chdir=TRUE)

#Create directories for output
output.folder <- "output"
dir.create.ifnot(output.folder)
dir.create.ifnot(paste0(output.folder, "/plots"))
dir.create.ifnot(paste0(output.folder, "/analysis"))
dir.create.ifnot(RData.folder)

###Start writing output to file###
sink(paste0(output.folder,"/Routput.txt"), append=FALSE, split=TRUE) 
cat(date(),"\n\nInputs provided by the user:\n")
sapply(input.variables,get)

###Get tidied data###
data.tidied <- get(data.fct.name)()

cat("\nFull network data\n")
data.tidied

###Simulate networks###
networks <- sample.networks(data.tidied = data.tidied,
                            save.networks = TRUE,
                            ref.trt = ref.trt,
                            n.disconnected.nodes = n.disconnected.nodes,
                            max.samples = max.samples)

cat("\nNames of the networks available for the analyses\n")
names(networks$datasets)

# I should make which.analyses global somehow
which.analyses <- define.all.analyses(names(networks$datasets), 
                                      c(rep("model-random.bug", # MODEL RANDOM
                                            length(networks$datasets)-1), 
                                        "model-fixed.bug"))   # MODEL FIXED

buildnrun.analyses(modelname, #"dnorm"
                   as.list(unlist(strsplit(params, " "))), # list("alpha.mn", "alpha.prc")
                   networks,
                   which.analyses,
                   inputs="inputs.general.R",
                   use.mapping,
                   save.mcmcs=TRUE,
                   traceplots=TRUE)

###Select which comparisons will be performed###
which.compare.list <- lapply(1:(length(networks$datasets)-1), function(i){
  which.compare.plot.1 <- cbind(c("Full-network", paste0("Network-",i)),
                                c("model-fixed.bug", "model-random.bug"),
                                c("Full-network-model-fixed", paste0("Network-",i,"-model-random")),
                                c("YES","NO"))
  colnames(which.compare.plot.1) <- c("Data","Model", "Description","Reference case for comparison")
  return(which.compare.plot.1)  #Reference case for comparison
}
)

cat("\nList of the posterior comparisons of interest:\n")
print(which.compare.list)

###Statistical comparisons###
out.results(inputs="inputs.general.R",
            which.analyses=which.analyses,
            which.compare.list=which.compare.list,
            revert.mapping = mapping.needed,
            metrics=TRUE,
            posteriors=print.posterior.plots)

###Close output file###
date()
sink()

# I NEED TO READ FROM THE PROPER csv FILE THAT STORES THE MOS
bin_table <- read.csv(paste0(output.folder, "/analysis/table.csv"))
measure_of_success <- bin_table[,3][length(bin_table[,3])]
analysis_name <- paste0(dsname, modelname, params)
if (!file.exists("mos_table.csv")) {
  analysis_name <- c(paste0(dsname, modelname, params))
  mos <- c(measure_of_success)
  df <- data.frame(analysis_name, mos, stringsAsFactors = FALSE)
  write.csv(file = "mos_table.csv", x = df, row.names = FALSE)
} else {
  mos_table <- read.csv("mos_table.csv", stringsAsFactors = FALSE)
  mos_table <- rbind(mos_table, c(paste0(dsname, modelname, params), measure_of_success))
  write.csv(file = "mos_table.csv", x = mos_table, row.names = FALSE)
}

if (plot_mos) {
  ## NOW PLOT THE MOSs
  mos_table <- read.csv("mos_table.csv")
  barplot(height = mos_table$mos, names.arg = mos_table$analysis_name)
} 

###here you can rename the folder
system(paste0("mv output ", str_remove_all(paste0("___", dsname, modelname, params), pattern = " ")))


