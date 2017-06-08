
# This function converts a time string to its military (24hr) format.
# Examples:
#          a) 2:14:30  -->  14:14:30
#          b) 8:25:00  -->  08:25:00
ConvertToMilitaryTime <- function(timeStr) {
  if(is.na(timeStr)){
    return(NA)
  }
  timeStr <- trimws(timeStr, which = "both")
  timeStr <- unlist(strsplit(timeStr, " "))[1]
  tokens <- unlist(strsplit(timeStr, ":"))
  if(length(tokens) < 3) {
    return(NA)
  }
  hour <- as.numeric(as.character(tokens[1]))
  if(hour <= 7) {
    hour <- hour + 12
  }
  hour <- as.character(hour)
  if(nchar(hour) < 2) {
    hour <- paste("0", hour, sep = "")
  }
  return(paste(as.character(hour), tokens[2], tokens[3], sep = ":"))
} 
