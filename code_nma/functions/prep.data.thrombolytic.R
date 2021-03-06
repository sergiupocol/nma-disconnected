prep.data.thrombolytic <- function(){
  
  thrombolytic.data <- read.csv("thrombolyticData.csv")
  
  trt.names <- as.character(unique(thrombolytic.data$treatment)) #rownames(gemtc::smoking$treatments)
  trt.numbers <- 1:length(trt.names)
  
  study.names <- unique(thrombolytic.data$study)
  study.numbers <- 1:length(study.names)
  
  trt.names.data.frame <- data.frame(cbind(trt.numbers, trt.names))

  
  thrombolytic.data$t.id <- as.numeric(as.character(mapvalues(thrombolytic.data$treatment,
                                                            trt.names, 
                                                            trt.numbers)))
  
  thrombolytic.data$s.id <- as.numeric(as.character(mapvalues(thrombolytic.data$study,
                                                            study.names, 
                                                            study.numbers)))
  
  
  thrombolytic.data <- rename(thrombolytic.data, c("responders"="r", "sampleSize"="n"))
  
  plot.network(paste0(output.folder,"/plots/raw_data_network.pdf"), 
               thrombolytic.data, 
               "", 
               trt.names.data.frame)
  
  write.treatment.description(paste0(output.folder,"/treatment-description.txt"),
                              trt.names.data.frame,
                              ref.trt)
  
  return(list("data"=thrombolytic.data, "treatments"=trt.names.data.frame))
  
}
