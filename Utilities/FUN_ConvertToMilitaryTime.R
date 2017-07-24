#Script Details -------------------------------------------------------------------------------------

#Script Name : FUN_ConvertToMilitaryTime.R

#Script Summary : 
#       This script contains one function required for tasktimes timestamp conversion.
#         1. FUN_ConvertToMilitaryTime : Function to convert time string to its military (24hr) format in the tasktimes file.

#Author & Reviewer Details --------------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/03/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date : 
#Reviewer E-Mail : hiranava@ufl.edu

#FUN_ConvertToMilitaryTime
FUN_ConvertToMilitaryTime <- function(timeStr) {
  
  # Input :- timeStr : This is the input timestamp string.
  # Output :- converted timestamp string to 24hr format.
  
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