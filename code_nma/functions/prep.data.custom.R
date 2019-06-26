prep.data.custom <- function(){
  
  ### PG making stuff up here, Aug 26th
  
  
  
  
  # SET DATASET TO THROMBOSIS
  library(gemtc)
  dataset <- as.data.frame(lapply(thrombolytic$data.ab, unlist))
  dataset

  
  dataset[,"t.id"] = as.numeric(dataset$treatment)
  
  names(dataset)[1] = "s.id"
  names(dataset)[3] = "r"
  names(dataset)[4] = "n"
  
  str(dataset)
  dataset$s.id <- as.numeric(dataset$s.id)
  
  col_order <- c("s.id", "t.id", "n", "r", "treatment")
  dataset <- dataset[,col_order][,-5]
  dataset
  
  
  
  
  ##### GENERALIZE THIS
  #trt.numbers <- order(unique(dataset$t.id))
  #trt.names <- c("SK", "ASPAC", "Ten", "AtPA", "Ret", "UK", "SKtPA", "tPA")
  trt.numbers <- 1:8
  trt.names <- c("ASPAC", "AtPA", "Ret", "SK", "SKtPA", "Ten", "tPA", "UK") # unique(dataset$treatment)
  trt.names.data.frame <- data.frame(cbind(trt.numbers, trt.names))
  trt.names.data.frame
  
  
  
  # trt.names.data.frame <- unique(dataset[,c("treatment", "t.id")])
  # 
  # 
  # trt.names.data.frame[,3] <- trt.names.data.frame[,1]
  # trt.names.data.frame <- trt.names.data.frame[,-1]
  # names(trt.names.data.frame) <- c("trt.numbers", "trt.names")
  # 
  # trt.numbers
  # trt.names <- as.character(unique(dataset$treatment))[trt.numbers]
  # 
  # trt.names.data.frame <- data.frame(cbind(trt.numbers, trt.names))
  # trt.names.data.frame
  plot.network(paste0(output.folder,"/plots/raw_data_network.pdf"), 
               dataset, 
               "", 
               trt.names.data.frame)
  
  write.treatment.description(paste0(output.folder,"/treatment-description.txt"),
                              trt.names.data.frame,
                              ref.trt)
  
  return(list("data"=dataset, "treatments"=trt.names.data.frame))
}
