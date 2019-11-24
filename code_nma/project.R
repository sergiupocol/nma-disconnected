rm(list = ls())
#Load functions
#install.packages(c("netmeta",
#                           "pcnetmeta",
#                           "runjags",
#                           "coda",
#                           "ggplot2",
#                           "dplyr",
#                           "plyr",
#                           "utils",
#                           "plotrix",
#                           "gemtc",
#                           "sampling",
#                           "reshape2",
#                           "stringr",
#                            "here",
#                            "gemtc"))

library(stringr)
library(ggplot2)
library(dplyr)
#library(future?)
set.seed(1)

# Grab the arguments passed in from the command line
comArgs <- unlist(strsplit(x = commandArgs(trailingOnly = TRUE), split = " "))
comArgs
inputs.file.name <- comArgs[1]#readline(prompt = "Dataset: \n")
model.name <- comArgs[2]#readline(prompt = "Model for RBE: \n")
params <- comArgs[3]#readline(prompt = "Parameters for above model: \n")
plot_mos <- as.logical(comArgs[4][1])#as.logical((readline(prompt = "Done comparing analyses? (TRUE or FALSE) \n"))[1])
debug <- as.logical(comArgs[5][1])
analysis_name <- paste0(inputs.file.name, model.name, params)

work.dir <- comArgs[6][1]
setwd(work.dir)



###Get inputs and header###
source(paste0("code_nma/inputs/inputs.general.R"), 
       local=FALSE, 
       chdir=TRUE)
input.variables <- ls()

source("code_nma/header.R", 
       local=FALSE, 
       chdir=TRUE)

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

buildnrun.analyses(model.name, #"dnorm"
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



bin_table <- read.csv(paste0(output.folder, "/analysis/table.csv"))
df <- data.frame(analysis_name, bin_table, stringsAsFactors = FALSE)

mos_table_name <- paste0(analysis_name, "___mos_table.csv")

if (!file.exists(mos_table_name)) {
	  df <- data.frame(analysis_name, bin_table, stringsAsFactors = FALSE)
  write.csv(file = mos_table_name, x = df, row.names = FALSE)
} else {
	  mos_table <- read.csv(mos_table_name, stringsAsFactors = FALSE)
  mos_table <- rbind(mos_table, df)
    write.csv(file = mos_table_name, x = mos_table, row.names = FALSE)
}

if (plot_mos) {
	  ## NOW PLOT THE MOSs
	  mos_table <- read.csv(mos_table_name)
  mos_table
    plot <- ggplot(mos_table, aes(analysis_name, Value)) + geom_tile(aes(fill = X.),colour = "white") +
	        scale_fill_gradient(low="white", high = "steelblue")
	  plot
} 



#bin_table <- read.csv(paste0(output.folder, "/analysis/table.csv"))
#df <- data.frame(analysis_name, bin_table, stringsAsFactors = FALSE)
#if (!file.exists("mos_table.csv")) {
  #df <- data.frame(analysis_name, bin_table, stringsAsFactors = FALSE)
 # write.csv(file = "mos_table.csv", x = df, row.names = FALSE)
#} else {
  #mos_table <- read.csv("mos_table.csv", stringsAsFactors = FALSE)
  #mos_table <- rbind(mos_table, df)
 # write.csv(file = "mos_table.csv", x = mos_table, row.names = FALSE)
#}

#if (plot_mos) {
#  ## NOW PLOT THE MOSs
#  mos_table <- read.csv("mos_table.csv")
#  mos_table
#  plot <- ggplot(mos_table, aes(analysis_name, Value)) + geom_tile(aes(fill = X.),colour = "white") +
#    scale_fill_gradient(low="white", high = "steelblue")
#  plot
#} 

## REMEMBER THE NEW NAMING CONVENTION diabetes ;dt(3)
###here you can rename the folder
#system(paste0("mv ", output.folder, " ", str_remove_all(paste0("___", inputs.file.name, model.name, params), pattern = " ")))


