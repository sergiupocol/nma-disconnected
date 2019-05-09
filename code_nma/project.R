# required for heatmap...
install.packages("gplots")
# Now that you've installed gplots, you need to make accessible within your library
library(gplots)
# for the colour customization...
install.packages("RColorBrewer", dependencies = TRUE)
library(RColorBrewer)
# Required for visual normality test:
install.packages("dplyr")
install.packages("ggpubr")
library("dplyr")
library("ggpubr")
install.packages("glmulti")
library("glmulti")
rm(list = ls())
install.packages("qqPlot")

setwd("~/Desktop/Dr. Beliveau Research/nma-disconnected-master")


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

# DATA TIDIED HAS FOLLOWUP
cat("\nFull network data\n")
data.tidied

###Simulate networks### DOES THE FUNCTION BELOW GET RID OF THE FOLLOWUP TIMES???
networks <- sample.networks(data.tidied = data.tidied,
                            save.networks = TRUE,
                            ref.trt = ref.trt,
                            n.disconnected.nodes = n.disconnected.nodes,
                            max.samples = max.samples)



#does networks have Followup time? YES
networks

cat("\nNames of the networks available for the analyses\n")
names(networks$datasets)

###Select which analyses will be performed###


##### HEREEEE SEE HOW I AM PASSING IN JUST THE DATASETS?? IT SHOULD INCLUDE THE FOLLOWUP TIMES

which.analyses <- define.all.analyses(names(networks$datasets), 
                                      c(rep("model-random.bug", 
                                            length(networks$datasets)-1), 
                                        "model-fixed.bug"))




cat("\nAnalyses to be conducted:\n")
which.analyses

save(which.analyses, file=paste0(RData.folder,"/whichanalyses.RData"))


###Run analyses### SOOOOO networks has follow up time!!!
run.analyses(networks,
             which.analyses,
             inputs="inputs.general.R",
             use.mapping=mapping.needed,
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


# colours for the palette
my_palette <- colorRampPalette(c("white", "dark grey"))(n = 299)


discrepancy_matrix_contrasts <- as.matrix(read.csv("~/Desktop/Dr. Beliveau Research/nma-disconnected-master/output_diab_2arms_2/analysis/results.csv"))
discrepancy_matrix_contrasts <- discrepancy_matrix_contrasts[which(startsWith(discrepancy_matrix_contrasts, "d_")),-1]
discrepancy_matrix_contrasts <- (matrix(as.numeric(unlist(discrepancy_matrix_contrasts)), nrow = nrow(discrepancy_matrix_contrasts)))

# plots the heatmap
graphics.off()
gplots::heatmap.2((discrepancy_matrix_contrasts), 
                  dendrogram = "none",
                  col = my_palette, 
                  na.color = "pink", 
                  trace = "none", 
                  density.info = "none",
                  Rowv=FALSE, Colv=FALSE)


# LOOKING FOR MODEL MISSPECIFICATION:
## HERE I USE THE FULL NETOWRK BECAUSE IT CONTAINS ALL THE DATA IT IS THE BE ALL AND END ALL
load("~/Desktop/Dr. Beliveau Research/nma-disconnected-master/RData_diab_2arms_2/Full-network-model-fixed/mcmc.RData")
full_network_alpha_summary <- (as.matrix(summary(run.jags.result)))[which(startsWith(colnames(run.jags.result$mcmc[[1]]), "alpha[")==TRUE), 4]
full_network_alpha_summary <- matrix(as.numeric(unlist(full_network_alpha_summary)), nrow = nrow(full_network_alpha_summary))
hist(full_network_alpha_summary, n = 30)
## LOOKS LIKE LEVY DISTRIBUTION

# VISUAL TEST FOR NORMALITY
# If normal then itd be bell shaped
ggpubr::ggdensity(full_network_alpha_summary)
# THE EXTREMES ARE PEAKED THE EXTREMES DONT FOLLOW THE NORMAL DISTRIBUTION!!!
# AND NETWORK - 4 FALLS HERE
ggpubr::ggqqplot(full_network_alpha_summary)
# NORMALITY FAILED
shapiro.test(full_network_alpha_summary)
# p-value of 0.4791





######## QQPLOT

# A Quantile-Quantile plot is a plot of the sorted quantiles of one data set against the sorted quantiles of another.
# If two distributions are similar, then the plot will lie close to the line y = x



# REMOVE MISSING VALUES
full_network_alpha_summary <- full_network_alpha_summary[!is.na(full_network_alpha_summary)]
# Now, we can find the TRUE length
n <- length(full_network_alpha_summary)

mean.fnas <- mean(full_network_alpha_summary)
var.fnas <- var(full_network_alpha_summary)
sd.fnas <- sd(full_network_alpha_summary)

# Partition (0, 1) for probabilities
probabilities <- (1:n) / (n + 1)


# Find the normal quantiles using the parameters of full netowrk alpha summary
t.quantiles = qt(probabilities, 0, sd(full_network_alpha_summary, na.rm = TRUE), df = 100)
t.quantiles = t.quantiles[!is.na(t.quantiles)]



plot(x = sort(t.quantiles), y = sort(full_network_alpha_summary), xlab = "Theoretical quantiles from normal distribution", 
     ylab = "Sample quantiles of FNAS", main = "t QQ Plot of FNAS")
abline()
dev.off()


###Close output file###



date()
sink()


