#Load the spark libraries
library(sparklyr)
library(dplyr)

#Create the connection to local Spark Cluster
sc <- spark_connect(master = "local")

#Set the directory to the location where the subsequence files are present
AllChunksFolder <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant Data/BOW_Files/"

#Set the directory where the codebook would be stored
codebookfolder <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant Data/Cleaned_Data/"

#Set Chunk Size when the script needs to be run as a standalone
#chunksize=3

#Set the Number of Atoms for the codebook
if(chunksize == 3)
{
  d<-32
  codebookfilename <- "codebook_W3_D32_dtw.Rdata"
  All3sChunksFileName <- paste(AllChunksFolder,"All_3s_Chunks.csv",sep = "")
  
  #Load All the 3s Data Chunks into a spark dataframe
  spark_read_csv(sc, "spark_all_3s_chunks_df", All3sChunksFileName)
  
  # Selecting V1 to V30 (acceleration data) for clustering
  cluster_df_tbl <- tbl(sc,"spark_all_3s_chunks_df") %>% select(starts_with("V",ignore.case = FALSE))
  
} else if(chunksize == 6)
{
  d<-64
  codebookfilename <- "codebook_W6_D64_dtw.Rdata"
  All6sChunksFileName <- paste(AllChunksFolder,"All_6s_Chunks.csv",sep = "")
  
  
  #Load All the 6s Data Chunks into a spark dataframe
  spark_read_csv(sc, "spark_all_6s_chunks_df", All6sChunksFileName)
  
  # Selecting V1 to V30 (acceleration data) for clustering
  cluster_df_tbl <- tbl(sc,"spark_all_6s_chunks_df") %>% select(starts_with("V",ignore.case = FALSE))
}


# Applying k-means clustering to obtain the codebook
set.seed(5855)
cluster_outcome <- cluster_df_tbl %>% ml_kmeans(centers = d)

# Codebook is learned and stored in a R dataframe
atoms <- sapply(1:d, FUN = function(x) {as.character(paste("D", x, sep = ""))})
codebook <- data.frame(Atom = atoms, cluster_outcome$centers, row.names = NULL)


#Save the codebook in a Rdata File
saveRDS(codebook, file = paste(codebookfolder,codebookfilename,sep = ""))
