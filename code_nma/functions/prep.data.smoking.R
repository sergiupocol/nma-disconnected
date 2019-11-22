prep.data.smoking <- function(){
  
  smoking.data <- read.csv("smokingData.csv")
  
  trt.names <- as.character(unique(smoking.data$treatment)) #rownames(gemtc::smoking$treatments)
  trt.numbers <- 1:length(trt.names)
  
  study.names <- unique(smoking.data$study)
  study.numbers <- 1:length(study.names)
  
  trt.names.data.frame <- data.frame(cbind(trt.numbers, trt.names))
  
  smoking.data$t.id <- as.numeric(as.character(mapvalues(smoking.data$treatment,
                                                            trt.names, 
                                                            trt.numbers)))
  
  smoking.data$s.id <- as.numeric(as.character(mapvalues(smoking.data$study,
                                                            study.names, 
                                                            study.numbers)))
  
  
  smoking.data <- rename(smoking.data, c("responders"="r", "sampleSize"="n"))
  
  plot.network(paste0(output.folder,"/plots/raw_data_network.pdf"), 
               smoking.data, 
               "", 
               trt.names.data.frame)
  
  write.treatment.description(paste0(output.folder,"/treatment-description.txt"),
                              trt.names.data.frame,
                              ref.trt)
  
  return(list("data"=smoking.data, "treatments"=trt.names.data.frame))
  
}
