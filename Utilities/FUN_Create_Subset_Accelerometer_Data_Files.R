# Receives three arguments:
#     1. dataFolder: the address where participants' data are located.
#     2. participantID: participant unique identifier
#     3. participant_task.df: taskTimes information for one participantID
#
# Finds wrist accelerometer files for the given participant and generates 4 RData files:
#     1. result.v1.df: a data.table consisting of V1 wrist accelerometer data
#     2. result.v2.df: a data.table consisting of V2 wrist accelerometer data
#     3. result.v3.df: a data.table consisting of V3 wrist accelerometer data
#     4. result.v4.df: a data.table consisting of V4 wrist accelerometer data
read.participant.files <- function(dataFolder, participantID, participant_task.df) {
  require(data.table)
  
  #Final Result Data Frame
  result_final.df <- data.frame(matrix(nrow = 0, ncol = 7))
  colnames(result_final.df) <- c("Timestamp", "X", "Y", "Z","timeOnly","VM","TaskLabel")
  
  # Locating participant's folder
  participantFolder <- dir(path = dataFolder, pattern = paste("^", participantID, ".*$", sep = ""))
  if(length(participantFolder) == 0) {
    stop("Participant Data are not found.") # if for a participant we do not have a data folder, we should not continue.
  }
  participantFolder <- paste(dataFolder, participantFolder, "/", sep = "")
  
  # Reading wrist accelerometer file for visit V1
  ppt.v1.df <-  data.frame(matrix(nrow = 0, ncol = 4))
  task.v1.df <- participant_task.df[which(participant_task.df$visit==1),]
  visitFileName <- dir(path = paste(participantFolder, "Wrist/", sep = ""), pattern = "^.*V1-.*csv$")
  if(length(visitFileName) == 0) {
    message("Participant does not have Wrist data for V1 visit.")
    write(paste("Participant ", participantID,"does not have Wrist data for V1 visit."),file=paste(dataFolder,"Logs/NoCSV_log.txt",sep=""),append=TRUE)
  } else {
    ppt.v1.df <- fread(input = paste(participantFolder, "Wrist/", visitFileName, sep = "")) # similar to read.csv() function.
    colnames(ppt.v1.df) <- c("Timestamp", "X", "Y", "Z") # Renaming columns name for convenicence.
    ppt.v1.df$temp <- 1:nrow(ppt.v1.df)
    ppt.v1.df$Timestamp <- as.character(ppt.v1.df$Timestamp)
    # We also need to construct a timeOnly column for a more efficient search. See the three lines below.
    ppt.v1.df[, timeOnly := as.character(unlist(strsplit(Timestamp, split = " "))[2]), by = temp]
    ppt.v1.df[, timeOnly := as.character(unlist(strsplit(timeOnly, split = "\\."))[1]), by = temp]
    ppt.v1.df[, temp := NULL] 
  }

  if(nrow(ppt.v1.df) > 0) {
  #Generate the result dataframe for storing V1 
  result.v1.df <- data.frame(matrix(nrow = 0, ncol = 7))  
  colnames(result.v1.df) <- c("Timestamp", "X", "Y", "Z","timeOnly","VM","TaskLabel")
  for(taskname in task.v1.df$task)
  {
    #Filtering accelerometer data based on start time and end time 
    temp.df <- ppt.v1.df[which(ppt.v1.df$timeOnly > task.v1.df$start.time[task.v1.df$task==taskname] & 
                                 ppt.v1.df$timeOnly < task.v1.df$end.time[task.v1.df$task==taskname]),]
    #Computing Vector Magnitude
    temp.df[, VM := sqrt(X^2 + Y^2 + Z^2)] 
    temp.df$TaskLabel <- taskname
    result.v1.df<- rbind(result.v1.df,temp.df)
  }
  
  if(nrow(task.v1.df) == 0)
  {
    message(paste("No RData File Generated for Visit V1 for Pariticipant ",participantID,"due to no tasktime information."))
    write(paste("No RData File Generated for Visit V1 for Pariticipant ",participantID,"due to no tasktime information."),file=paste(dataFolder,"Logs/NoTaskTime_log.txt",sep=""),append=TRUE)
    
  }
  else if(nrow(result.v1.df)>0)
  {
    result_final.df<- rbind(result.v1.df,result_final.df)
    #saveRDS(result.v1.df, file = paste(participantFolder, "Wrist/", paste(unlist(strsplit(visitFileName, "\\."))[1],".Rdata",sep=""), sep=""))
    message("V1 data processing complete.")
    
  } else {
    
    message(paste("No RData File Generated for Visit V1 for Pariticipant ",participantID,"due to no accelerometer data within given time range."))
    write(paste("No RData File Generated for Visit V1 for Pariticipant ",participantID,"due to no accelerometer data within given time range."),file=paste(dataFolder,"Logs/NoAcc_TimeRange_log.txt",sep=""),append=TRUE)
    
    
    }
  }
  
  # Similar to reading wrist accelerometer file for visit 1.
  ppt.v2.df <-  data.frame(matrix(nrow = 0, ncol = 4))
  task.v2.df <- participant_task.df[which(participant_task.df$visit==2),]
  visitFileName <- dir(path = paste(participantFolder, "Wrist/", sep = ""), pattern = "^.*V2-.*csv$")
  if(length(visitFileName) == 0) {
    message("Participant does not have Wrist data for V2 visit.")
    write(paste("Participant ", participantID,"does not have Wrist data for V2 visit."),file=paste(dataFolder,"Logs/NoCSV_log.txt",sep=""),append=TRUE)
    
  } else {
    ppt.v2.df <- fread(input = paste(participantFolder, "Wrist/", visitFileName, sep = ""))
    colnames(ppt.v2.df) <- c("Timestamp", "X", "Y", "Z")
    
    ppt.v2.df$temp <- 1:nrow(ppt.v2.df)
    ppt.v2.df$Timestamp <- as.character(ppt.v2.df$Timestamp)
    ppt.v2.df[, timeOnly := as.character(unlist(strsplit(Timestamp, split = " "))[2]), by = temp]
    ppt.v2.df[, timeOnly := as.character(unlist(strsplit(timeOnly, split = "\\."))[1]), by = temp]
    ppt.v2.df[, temp := NULL]
  }
  
  if(nrow(ppt.v2.df) > 0) {
  #Generate the result dataframe for storing V2 
  result.v2.df <- data.frame(matrix(nrow = 0, ncol = 7))  
  colnames(result.v2.df) <- c("Timestamp", "X", "Y", "Z","timeOnly","VM","TaskLabel")
  for(taskname in task.v2.df$task)
  {
    #Filtering accelerometer data based on start time and end time 
    temp.df <- ppt.v2.df[which(ppt.v2.df$timeOnly > task.v2.df$start.time[task.v2.df$task==taskname] & 
                                 ppt.v2.df$timeOnly < task.v2.df$end.time[task.v2.df$task==taskname]),]
    #Computing Vector Magnitude
    temp.df[, VM := sqrt(X^2 + Y^2 + Z^2)] 
    temp.df$TaskLabel <- taskname
    result.v2.df<- rbind(result.v2.df,temp.df)
  }
  
  if(nrow(task.v2.df) == 0)
  {
    message(paste("No RData File Generated for Visit V2 for Pariticipant ",participantID,"due to no tasktime information."))
    write(paste("No RData File Generated for Visit V2 for Pariticipant ",participantID,"due to no tasktime information."),file=paste(dataFolder,"Logs/NoTaskTime_log.txt",sep=""),append=TRUE)
    
  } else if(nrow(result.v2.df)>0)
  {
    result_final.df<- rbind(result.v2.df,result_final.df)
    #saveRDS(result.v2.df, file = paste(participantFolder, "Wrist/", paste(unlist(strsplit(visitFileName, "\\."))[1],".Rdata",sep=""), sep=""))
    message("V2 data processing complete.")  
  } else {
    
    message(paste("No RData File Generated for Visit V2 for Pariticipant ",participantID,"due to no accelerometer data within given time range."))
    write(paste("No RData File Generated for Visit V2 for Pariticipant ",participantID,"due to no accelerometer data within given time range."),file=paste(dataFolder,"Logs/NoAcc_TimeRange_log.txt",sep=""),append=TRUE)
    
    }
  }
  
  # Similar to reading wrist accelerometer file for visit 1.
  ppt.v3.df <-  data.frame(matrix(nrow = 0, ncol = 4))
  task.v3.df <- participant_task.df[which(participant_task.df$visit==3),]
  visitFileName <- dir(path = paste(participantFolder, "Wrist/", sep = ""), pattern = "^.*V3-.*csv$")
  if(length(visitFileName) == 0) {
    message("Participant does not have Wrist data for V3 visit.")
    write(paste("Participant ", participantID,"does not have Wrist data for V3 visit."),file=paste(dataFolder,"Logs/NoCSV_log.txt",sep=""),append=TRUE)
    
  } else {
    ppt.v3.df <- fread(input = paste(participantFolder, "Wrist/", visitFileName, sep = ""))
    colnames(ppt.v3.df) <- c("Timestamp", "X", "Y", "Z")
    
    ppt.v3.df$temp <- 1:nrow(ppt.v3.df)
    ppt.v3.df$Timestamp <- as.character(ppt.v3.df$Timestamp)
    ppt.v3.df[, timeOnly := as.character(unlist(strsplit(Timestamp, split = " "))[2]), by = temp]
    ppt.v3.df[, timeOnly := as.character(unlist(strsplit(timeOnly, split = "\\."))[1]), by = temp]
    ppt.v3.df[, temp := NULL]
  }
  
  if(nrow(ppt.v3.df) > 0) {
  #Generate the result dataframe for storing V3 
  result.v3.df <- data.frame(matrix(nrow = 0, ncol = 7))  
  colnames(result.v3.df) <- c("Timestamp", "X", "Y", "Z","timeOnly","VM","TaskLabel")
  for(taskname in task.v3.df$task)
  {
    #Filtering accelerometer data based on start time and end time 
    temp.df <- ppt.v3.df[which(ppt.v3.df$timeOnly > task.v3.df$start.time[task.v3.df$task==taskname] & 
                                 ppt.v3.df$timeOnly < task.v3.df$end.time[task.v3.df$task==taskname]),]
    #Computing Vector Magnitude
    temp.df[, VM := sqrt(X^2 + Y^2 + Z^2)] 
    temp.df$TaskLabel <- taskname
    result.v3.df<- rbind(result.v3.df,temp.df)
  }
  
  if(nrow(task.v3.df) == 0)
  {
    message(paste("No RData File Generated for Visit V3 for Pariticipant ",participantID,"due to no tasktime information."))
    write(paste("No RData File Generated for Visit V3 for Pariticipant ",participantID,"due to no tasktime information."),file=paste(dataFolder,"Logs/NoTaskTime_log.txt",sep=""),append=TRUE)
    
  } else if(nrow(result.v3.df)>0)
  {
    result_final.df<- rbind(result.v3.df,result_final.df)
    #saveRDS(result.v3.df, file = paste(participantFolder, "Wrist/", paste(unlist(strsplit(visitFileName, "\\."))[1],".Rdata",sep=""), sep=""))
    message("V3 data processing complete.")  
  } else {
    
    message(paste("No RData File Generated for Visit V3 for Pariticipant ",participantID,"due to no accelerometer data within given time range."))
    write(paste("No RData File Generated for Visit V3 for Pariticipant ",participantID,"due to no accelerometer data within given time range."),file=paste(dataFolder,"Logs/NoAcc_TimeRange_log.txt",sep=""),append=TRUE)
    
    }
  } 
  
  
  # Similar to reading wrist accelerometer file for visit 1.
  ppt.v4.df <-data.frame(matrix(nrow = 0, ncol = 4))
  task.v4.df <- participant_task.df[which(participant_task.df$visit==4),]
  visitFileName <- dir(path = paste(participantFolder, "Wrist/", sep = ""), pattern = "^.*V4-.*csv$")
  if(length(visitFileName) == 0) {
    message("Participant does not have Wrist data for V4 visit.")
    write(paste("Participant ", participantID,"does not have Wrist data for V4 visit."),file=paste(dataFolder,"Logs/NoCSV_log.txt",sep=""),append=TRUE)
    
  } else {
    ppt.v4.df <- fread(input = paste(participantFolder, "Wrist/", visitFileName, sep = ""))
    colnames(ppt.v4.df) <- c("Timestamp", "X", "Y", "Z")
    
    ppt.v4.df$temp <- 1:nrow(ppt.v4.df)
    ppt.v4.df$Timestamp <- as.character(ppt.v4.df$Timestamp)
    ppt.v4.df[, timeOnly := as.character(unlist(strsplit(Timestamp, split = " "))[2]), by = temp]
    ppt.v4.df[, timeOnly := as.character(unlist(strsplit(timeOnly, split = "\\."))[1]), by = temp]
    ppt.v4.df[, temp := NULL]
  }
  
  if(nrow(ppt.v4.df) > 0) {
  #Generate the result dataframe for storing V4 
  result.v4.df <- data.frame(matrix(nrow = 0, ncol = 7))  
  colnames(result.v4.df) <- c("Timestamp", "X", "Y", "Z","timeOnly","VM","TaskLabel")
  for(taskname in task.v4.df$task)
  {
    #Filtering accelerometer data based on start time and end time
    temp.df <- ppt.v4.df[which(ppt.v4.df$timeOnly > task.v4.df$start.time[task.v4.df$task==taskname] & 
                                 ppt.v4.df$timeOnly < task.v4.df$end.time[task.v4.df$task==taskname]),]
    #Computing Vector Magnitude
    temp.df[, VM := sqrt(X^2 + Y^2 + Z^2)] 
    temp.df$TaskLabel <- taskname
    result.v4.df<- rbind(result.v4.df,temp.df)
  }
  
  
  if(nrow(task.v4.df) == 0)
  {
    message(paste("No RData File Generated for Visit V4 for Pariticipant ",participantID,"due to no tasktime information."))
    write(paste("No RData File Generated for Visit V4 for Pariticipant ",participantID,"due to no tasktime information."),file=paste(dataFolder,"Logs/NoTaskTime_log.txt",sep=""),append=TRUE)
    
  }
  else if(nrow(result.v4.df)>0)
  {
    
    result_final.df<- rbind(result.v4.df,result_final.df)
    #saveRDS(result.v4.df, file = paste(participantFolder, "Wrist/", paste(unlist(strsplit(visitFileName, "\\."))[1],".Rdata",sep=""), sep=""))
    message("V4 data processing complete.")
    
  } else {
    
    message(paste("No RData File Generated for Visit V4 for Pariticipant ",participantID,"due to no accelerometer data within given time range."))
    write(paste("No RData File Generated for Visit V4 for Pariticipant ",participantID,"due to no accelerometer data within given time range."),file=paste(dataFolder,"Logs/NoAcc_TimeRange_log.txt",sep=""),append=TRUE)
    
    }
  }
  
  result_final.df
  
}