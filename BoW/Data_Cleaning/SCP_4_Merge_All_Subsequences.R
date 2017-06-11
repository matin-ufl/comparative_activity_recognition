#Set the working directory to the location where the scripts and function R files are located

setwd("~/Desktop/Data_Mining_Project/Data_Cleaning_Code/My_Code")

#Set the directory to the location where the subsequence files are present

dataFolder <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant Data/BOW_Files/"

#Set Chunk Size when the script needs to be run as a standalone
#chunksize=3

if (chunksize == 3)
{
  # Merging all 3s BoW chunks into one data.frame
  l <- dir(path = paste(dataFolder,"Three-second chunks/",sep=""), pattern = "^.*.Rdata$") 
  chunkfilename<- "All_3s_Chunks.csv"
  
  #Merge All the Chunks for all participants
  allChunks.df <- data.frame(matrix(nrow = 0, ncol = 35))
  for(fileName in l) {
    bowChunks.df <- readRDS(paste(dataFolder, "Three-second chunks/", fileName, sep = ""))
    allChunks.df <- rbind(allChunks.df, bowChunks.df)
  }
  
} else if (chunksize == 6)
{
  # Merging all 6s BoW chunks into one data.frame
  l <- dir(path = paste(dataFolder,"Six-second chunks/",sep=""), pattern = "^.*.Rdata$") 
  chunkfilename<- "All_6s_Chunks.csv"
  
  #Merge All the Chunks for all participants
  allChunks.df <- data.frame(matrix(nrow = 0, ncol = 35))
  for(fileName in l) {
    bowChunks.df <- readRDS(paste(dataFolder, "Six-second chunks/", fileName, sep = ""))
    allChunks.df <- rbind(allChunks.df, bowChunks.df)
  }
}

rm(fileName, bowChunks.df)

# Removing unnecessary tasks from this raw dataset
keep.these.tasks <- c("LIGHT GARDENING", "YARD WORK", "DIGGING", "LEISURE WALK",
                      "RAPID WALK", "SWEEPING", "PREPARE SERVE MEAL", "STRAIGHTENING UP DUSTING",
                      "WASHING DISHES", "UNLOADING STORING DISHES", "VACUUMING", "WALKING AT RPE 1", 
                      "PERSONAL CARE", "DRESSING", "WALKING AT RPE 5", "STAIR DESCENT",
                      "STAIR ASCENT", "TRASH REMOVAL", "REPLACING SHEETS ON A BED", "STRETCHING YOGA",
                      "MOPPING", "COMPUTER WORK", "LAUNDRY WASHING", "SHOPPING",
                      "IRONING", "LIGHT HOME MAINTENANCE", "WASHING WINDOWS", "HEAVY LIFTING",
                      "STRENGTH EXERCISE LEG CURL", "STRENGTH EXERCISE CHEST PRESS", "STRENGTH EXERCISE LEG EXTENSION", "TV WATCHING",
                      "STANDING STILL")
rawBoW.df <- allChunks.df[allChunks.df$Task %in% keep.these.tasks, ]
rawBoW.df$PID <- as.character(rawBoW.df$PID); 
rawBoW.df$Task <- as.character(rawBoW.df$Task); 
rawBoW.df$Start.Time <- as.character(rawBoW.df$Start.Time); 
rawBoW.df$End.Time <- as.character(rawBoW.df$End.Time)

#Save the merged dataframe into a csv file
write.csv(rawBoW.df, file = paste(dataFolder,chunkfilename, sep=""), row.names=FALSE, sep = ",")
