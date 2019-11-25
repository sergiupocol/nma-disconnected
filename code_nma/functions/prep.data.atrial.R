prep.data.atrial <- function(){
  
  atrial.data <- read.csv("atrialData.csv")
  
  trt.names <- as.character(unique(atrial.data$treatment)) #rownames(gemtc::atrial$treatments)
  trt.numbers <- 1:length(trt.names)
  
  study.names <- unique(atrial.data$study)
  study.numbers <- 1:length(study.names)
  
  trt.names.data.frame <- data.frame(cbind(trt.numbers, trt.names))


  n.arms <- table(atrial.data$study)
  
  which.2.arms <- as.numeric(names(which(n.arms == 2)))
  
  atrial.2.arms.only <- atrial.data[which(atrial.data$study %in% which.2.arms),]



  cat("Complete atrial data\n")
  print(atrial.data)
  cat("atrial data with only 2 arms >>>\n")
  print(atrial.2.arms.only)


  atrial.data <- atrial.2.arms.only
  
  atrial.data$t.id <- as.numeric(as.character(mapvalues(atrial.data$treatment,
                                                            trt.names, 
                                                            trt.numbers)))
  
  atrial.data$s.id <- as.numeric(as.character(mapvalues(atrial.data$study,
                                                            study.names, 
                                                            study.numbers)))
  
  
  atrial.data <- rename(atrial.data, c("responders"="r", "sampleSize"="n"))
  
  plot.network(paste0(output.folder,"/plots/raw_data_network.pdf"), 
               atrial.data, 
               "", 
               trt.names.data.frame)
  
  write.treatment.description(paste0(output.folder,"/treatment-description.txt"),
                              trt.names.data.frame,
                              ref.trt)
  
  return(list("data"=atrial.data, "treatments"=trt.names.data.frame))
  
}
