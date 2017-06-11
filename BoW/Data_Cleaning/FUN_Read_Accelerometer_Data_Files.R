# Receives two arguments:
#     1. dataFolder: the address where participants' data are located.
#     2. participantID: participant unique identifier
#
# Finds wrist accelerometer files for the given participant and returns a list:
#     1. ppt.v1.df: a data.table consisting of V1 wrist accelerometer data
#     2. ppt.v2.df: a data.table consisting of V2 wrist accelerometer data
#     3. ppt.v3.df: a data.table consisting of V3 wrist accelerometer data
#     4. ppt.v4.df: a data.table consisting of V4 wrist accelerometer data
read.participant.files <- function(dataFolder, participantID) {
  require(data.table)
  
  # Locating participant's folder
  participantFolder <- dir(path = dataFolder, pattern = paste("^", participantID, ".*$", sep = ""))
  if(length(participantFolder) == 0) {
    stop("Participant Data are not found.") # if for a participant we do not have a data folder, we should not continue.
  }
  participantFolder <- paste(dataFolder, participantFolder, "/", sep = "")
  
  # Reading wrist accelerometer file for visit V1
  ppt.v1.df <- NA
  visitFileName <- dir(path = paste(participantFolder, "Wrist/", sep = ""), pattern = "^.*V1-.*$")
  if(length(visitFileName) == 0) {
    warning("Participant does not have Wrist data for V1 visit.")
  } else {
    ppt.v1.df <- fread(input = paste(participantFolder, "Wrist/", visitFileName, sep = "")) # similar to read.csv() function.
    colnames(ppt.v1.df) <- c("Timestamp", "X", "Y", "Z") # Renaming columns name for convenicence.
    
    ppt.v1.df$temp <- 1:nrow(ppt.v1.df)
    ppt.v1.df$Timestamp <- as.character(ppt.v1.df$Timestamp)
    ppt.v1.df[, VM := sqrt(X^2 + Y^2 + Z^2)] # calculating Vector Magnitude and adding a column 'VM' to our dataset
    # We also need to construct a timeOnly column for a more efficient search. See the three lines below.
    ppt.v1.df[, timeOnly := as.character(unlist(strsplit(Timestamp, split = " "))[2]), by = temp]
    ppt.v1.df[, timeOnly := as.character(unlist(strsplit(timeOnly, split = "\\."))[1]), by = temp]
    ppt.v1.df[, temp := NULL] 
  }
  message("V1 data loaded.")
  
  # Similar to reading wrist accelerometer file for visit 1.
  ppt.v2.df <- NA
  visitFileName <- dir(path = paste(participantFolder, "Wrist/", sep = ""), pattern = "^.*V2-.*$")
  if(length(visitFileName) == 0) {
    warning("Participant does not have Wrist data for V2 visit.")
  } else {
    ppt.v2.df <- fread(input = paste(participantFolder, "Wrist/", visitFileName, sep = ""))
    colnames(ppt.v2.df) <- c("Timestamp", "X", "Y", "Z")
    
    ppt.v2.df$temp <- 1:nrow(ppt.v2.df)
    ppt.v2.df$Timestamp <- as.character(ppt.v2.df$Timestamp)
    ppt.v2.df[, VM := sqrt(X^2 + Y^2 + Z^2)]
    ppt.v2.df[, timeOnly := as.character(unlist(strsplit(Timestamp, split = " "))[2]), by = temp]
    ppt.v2.df[, timeOnly := as.character(unlist(strsplit(timeOnly, split = "\\."))[1]), by = temp]
    ppt.v2.df[, temp := NULL]
  }
  message("V2 data loaded.")
  
  # Similar to reading wrist accelerometer file for visit 1.
  ppt.v3.df <- NA
  visitFileName <- dir(path = paste(participantFolder, "Wrist/", sep = ""), pattern = "^.*V3-.*$")
  if(length(visitFileName) == 0) {
    warning("Participant does not have Wrist data for V3 visit.")
  } else {
    ppt.v3.df <- fread(input = paste(participantFolder, "Wrist/", visitFileName, sep = ""))
    colnames(ppt.v3.df) <- c("Timestamp", "X", "Y", "Z")
    
    ppt.v3.df$temp <- 1:nrow(ppt.v3.df)
    ppt.v3.df$Timestamp <- as.character(ppt.v3.df$Timestamp)
    ppt.v3.df[, VM := sqrt(X^2 + Y^2 + Z^2)]
    ppt.v3.df[, timeOnly := as.character(unlist(strsplit(Timestamp, split = " "))[2]), by = temp]
    ppt.v3.df[, timeOnly := as.character(unlist(strsplit(timeOnly, split = "\\."))[1]), by = temp]
    ppt.v3.df[, temp := NULL]
  }
  message("V3 data loaded.")
  
  # Similar to reading wrist accelerometer file for visit 1.
  ppt.v4.df <- NA
  visitFileName <- dir(path = paste(participantFolder, "Wrist/", sep = ""), pattern = "^.*V4-.*$")
  if(length(visitFileName) == 0) {
    warning("Participant does not have Wrist data for V4 visit.")
  } else {
    ppt.v4.df <- fread(input = paste(participantFolder, "Wrist/", visitFileName, sep = ""))
    colnames(ppt.v4.df) <- c("Timestamp", "X", "Y", "Z")
    
    ppt.v4.df$temp <- 1:nrow(ppt.v4.df)
    ppt.v4.df$Timestamp <- as.character(ppt.v4.df$Timestamp)
    ppt.v4.df[, VM := sqrt(X^2 + Y^2 + Z^2)]
    ppt.v4.df[, timeOnly := as.character(unlist(strsplit(Timestamp, split = " "))[2]), by = temp]
    ppt.v4.df[, timeOnly := as.character(unlist(strsplit(timeOnly, split = "\\."))[1]), by = temp]
    ppt.v4.df[, temp := NULL]
  }
  message("V4 data loaded.")
  
  result <- list(ppt.v1.df, ppt.v2.df, ppt.v3.df, ppt.v4.df)
  result
}