library(dplyr)
library(dtw)
#ADAD151 as trainning
v1 <- readRDS("/media/abhijay/f03392b2-4aa9-4ca9-865e-1d92b54fab3d/Participant_Data/ADAD151/Wrist/ADAD15103222016V1-wristRAW.Rdata")
v2 <- readRDS("/media/abhijay/f03392b2-4aa9-4ca9-865e-1d92b54fab3d/Participant_Data/ADAD151/Wrist/ADAD15104112016V2-wristRAW.Rdata")
v3 <- readRDS("/media/abhijay/f03392b2-4aa9-4ca9-865e-1d92b54fab3d/Participant_Data/ADAD151/Wrist/ADAD15104152016V3-wristRAW.Rdata")
v4 <- readRDS("/media/abhijay/f03392b2-4aa9-4ca9-865e-1d92b54fab3d/Participant_Data/ADAD151/Wrist/ADAD15104292016V4-wristRAW.Rdata")

ppt1 <- rbind(v1,v2,v3,v4)
ppt1 <- as.data.frame(ppt1)

#test set and creating smaller chunks
test <- readRDS("/media/abhijay/f03392b2-4aa9-4ca9-865e-1d92b54fab3d/Participant_Data/ADMC021/Wrist/ADMC02102042015V1-wristRAW.Rdata")
test <- test[test$TaskLabel == "LEISURE WALK",]
chunk <- 2000
n <- nrow(test)
r  <- rep(1:ceiling(n/chunk),each=chunk)[1:n]
test_chunks <- split(test,r)

#partion training data into different activities
features <- unique(ppt1$TaskLabel)
task <- list()
for(i in 1:length(features)){
task[[i]] <- ppt1[ppt1$TaskLabel == features[i],]
}

###using dtw to make feature with the test set###
dmin <- 1000
#chunking the data into smaller time series
feature_list<-rep(0,33)
for(i in 1:length(features)){
chunk <- 2000
n <- nrow(task[[i]])
r  <- rep(1:ceiling(n/chunk),each=chunk)[1:n]
train_chunks <- split(task[[i]],r)
#calculating minumum distance usin dtw
for(j in 1:length(test_chunks)){
  for(k in 1:length(train_chunks)){
    t_chunk <- as.data.frame(train_chunks[k])
    te_chunk <- as.data.frame(test_chunks[j])
    d <- dtw(t_chunk[,6],te_chunk[,6])$distance
    if(d<dmin){
      dmin<-d
    }
  }
}
feature_list[i] <- dmin
dmin <- 1000
}


