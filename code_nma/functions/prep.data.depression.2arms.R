prep.data.depression.2arms <- function(){
  
  depression.data <- read.csv("depressionData.csv")


  n.arms <- table(depression.data$study)
  print("OIIIIII: >>>>>>>>\n")
  print(n.arms)
  which.2.arms <- (names(which(n.arms == 2)))
  
  depression.2.arms.only <- depression.data[which(depression.data$study %in% which.2.arms),]



  cat("Complete depression data\n")
  print(depression.data)
  cat("depression data with only 2 arms >>>\n")
  print(depression.2.arms.only)
  depression.data <- depression.2.arms.only
  #atrial.data <- as.data.frame(lapply(atrial.data, unlist))
  
  trt.names <- as.character(unique(depression.data$treatment)) #rownames(gemtc::depression$treatments)
  trt.numbers <- 1:length(trt.names)
  
  study.names <- unique(depression.data$study)
  study.numbers <- 1:length(study.names)
  
  trt.names.data.frame <- data.frame(cbind(trt.numbers, trt.names))



 
  
  depression.data$t.id <- as.numeric(as.character(mapvalues(depression.data$treatment,
                                                            trt.names, 
                                                            trt.numbers)))
  
  depression.data$s.id <- as.numeric(as.character(mapvalues(depression.data$study,
                                                            study.names, 
                                                            study.numbers)))
  
  
  depression.data <- rename(depression.data, c("responders"="r", "sampleSize"="n"))
  
  plot.network(paste0(output.folder,"/plots/raw_data_network.pdf"), 
               depression.data, 
               "", 
               trt.names.data.frame)
  
  write.treatment.description(paste0(output.folder,"/treatment-description.txt"),
                              trt.names.data.frame,
                              ref.trt)
  
  return(list("data"=depression.data, "treatments"=trt.names.data.frame))
  
}
