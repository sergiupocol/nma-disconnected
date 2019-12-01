workdir <- work.dir#"/home/spocol/projects/def-a2belive/spocol/nma-disconnected"

other.inputs <- inputs.file.name#####"inputs.diabetes.2arms.2.debug.R"
paste0("code_nma/inputs/", other.inputs)
source(here::here(paste0("code_nma/inputs/", other.inputs)), local = TRUE)

print.posterior.plots <- TRUE

vars.monitor <- c("sig2","d","alpha")
var.trt.names <- c("d")
var.trial.names <- c("alpha")

var.equiv.table <- data.frame(cbind(c(list("d"), list("alpha")),
                                    c(2, NA)))

rownames(var.equiv.table) <- c("t.id", "s.id")
colnames(var.equiv.table) <- c("Vars.monitored","Reference")

mapping.needed <- TRUE

if (debug) {
  n.chains <- 1
  n.samples <- 101
  n.adapt <- 101
  thin <- 1
  n.burnin <- 0
} else {
  n.chains <- 3
  thin <- 10
  n.samples <- 300000 / thin
  n.adapt <- 3000
  n.burnin <- 50000
}

max.samples <- 35


# Make the output folders unique
#RData.folder <- paste0(RData.folder, analysis_name)
output.folder <- paste0("output___",analysis_name)

