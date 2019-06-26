#Load functions
invisible(sapply(paste0("functions/",list.files("functions")),source))

#Load packages
install.require.packages(c("netmeta",
                           "pcnetmeta",
                           "runjags",
                           "coda",
                           "ggplot2",
                           "dplyr",
                           "plyr",
                           "utils",
                           "plotrix",
                           "gemtc",
                           "sampling",
                           "reshape2"))

#Set working directory
setwd(workdir)




