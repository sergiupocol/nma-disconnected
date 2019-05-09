workdir <- "~/Desktop/Dr. Beliveau Research/nma-disconnected-master"


other.inputs <- "inputs.diabetes.2arms.2.R"
source(other.inputs)

print.posterior.plots <- TRUE

vars.monitor <- c("sig2","d","alpha")
var.trt.names <- c("d")
var.trial.names <- c("alpha")

var.equiv.table <- data.frame(cbind(c(list("d"), list("alpha")),
                                    c(2, NA)))

rownames(var.equiv.table) <- c("t.id", "s.id")
colnames(var.equiv.table) <- c("Vars.monitored","Reference")

mapping.needed <- TRUE

