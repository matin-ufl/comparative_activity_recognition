# __________________________________________
# Constructing statistical variables for 10Hz wrist accelerometer data
# 
# ___________
# Matin Kheirkhahan (matinkheirkhahan@ufl.edu)
# __________________________________________
setwd("~/Workspaces/R workspace/Comparative Activity Recognition/Statisical Model/")
source("FUN_Variables_for_One_Participant.R")

# Training set ------------------------------------
stat.training.df <- data.frame(matrix(nrow = 0, ncol = 10))
folder <- "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/New Raw Data/Downsampled_Files/Training_Set/"
filenames <- dir(path = folder)
for(filename in filenames) {
     message(paste(filename, "..."))
     PID <- unlist(strsplit(filename, split = "_"))[1]
     out <- calculate.statistical.variables(paste(folder, filename, sep = ""), PID)
     stat.training.df <- rbind(stat.training.df, out)
}
rm(out)
saveRDS(stat.training.df, file = "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Constructed Datasets/Statistical Variables/traininSet.Rdata")


# Test set ------------------------------------
stat.test.df <- data.frame(matrix(nrow = 0, ncol = 10))
folder <- "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/New Raw Data/Downsampled_Files/Testing_Set/"
filenames <- dir(path = folder)
for(filename in filenames) {
     PID <- unlist(strsplit(filename, split = "_"))[1]
     out <- calculate.statistical.variables(paste(folder, filename, sep = ""), PID)
     stat.test.df <- rbind(stat.test.df, out)
}
rm(out)
saveRDS(stat.test.df, file = "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Constructed Datasets/Statistical Variables/testSet.Rdata")