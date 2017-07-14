# Bag of Words Model for Activity Recognition

This project is used to classify various day to day activities (like TV watching, Walking, Standing etc.) into two different categories. 
One category is Sedentary and Non-Sedentary. The other is the Locomotion and Stationary. The objective of this project is to read and analyse the 
raw accelerometer data of 146 participants and predict the type of activities that they were doing. The prediction task is done by building a Bag of Words Model
and training data for 126 participants in that model. The rest of the 20 participants is the testing data which is used to check the accuracy of the activity
prediction of the model.

## Getting Started

These step by step instructions will help in executing each of the scripts required for performing the Activity Recognition project.

### Prerequisites Softwares

These scripts are written in R Language and it requires the R-Studio software for execution. 
R-Studio Version - 1.0.143 has been used to develop these scripts. 

Please Download and Install the required R-Studio software from the following link as per your operating system:

https://www.rstudio.com/products/rstudio/download/



### Installing R-Libraries

Run the R-Studio and open a blank R-Script :

Please install the following R-Libraries :-

1. data.table
2. dplyr
3. pbapply
4. sparklyr
5. dtw
6. e1071
7. rpart
8. randomForest
9. caret
10. MASS

Run the following commands to install the libraries:

```
install.packages("data.table")
install.packages("dplyr")
install.packages("pbapply")
install.packages("sparklyr")
install.packages("dtw")
install.packages("e1071")
install.packages("rpart")
install.packages("randomForest")
install.packages("caret")
install.packages("MASS")
```

And then run the following commands to test if they are correctly installed. Please ignore the warning messages.

```
library(data.table)
library(dplyr)
library(pbapply)
library(sparklyr)
library(dtw)
library(e1071)
library(rpart)
library(randomForest)
library(caret)
library(MASS)

```

### Prerequisite Folder Structure


Create a folder Raw_Data and place the tasktimes csv file in it. 

Then, create a new folder Participant_Data inside Raw_Data folder and store the raw accelerometer data folders for each participant in this folder. 

Then, Inside Participant_Data Folder create the following directory and sub-directory structure :

i) Original_SubSet   |-> Training_Set

                     |-> Testing_Set 
                                                   
ii) Downsampled_Files |-> Training_Set

                      |-> Testing_Set 
                                                   
iii) BOW_Files        |-> Three-second chunks |-> Training_Set

                                              |-> Testing_Set 
					      
                      |-> Six-second chunks |-> Training_Set
		      
                                            |-> Testing_Set
					  
iv) Cleaned_Data      |-> D32 |-> Training_Set

                              |-> Testing_Set    
			      
                      |-> D64 |-> Training_Set
		      
                              |-> Testing_Set
			      
                      |-> Model_Output 
		      
v) Logs
                              
Please note that all the above folder names are case sensitive.

## Running the scripts sequentially

After all the softwares and libraries are installed and all the folders created with the raw data folders placed in them, 
the first task would be execute the data cleaning scripts in the following sequence as mentioned below:

### Data Cleaning Tasks 

#### Script-1 -- SCP_ConvertTaskTimeFile.R

This script converts the taskTimes file from .csv to .Rdata by converting the start and the end timestamps to 24hr format.
It also removes the invalid records where the start time is greater than the end time and there are NA values in any of the records.

Before execution of this script, Please open the file and set the parameters in the Parameters settings section as per the instructions in the 
script file:

```
#Set the working directory to the location where the scripts and function R files are located 
setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")
		
#Set the directory to the location where the taskTimes_all.csv file is located
DATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/"

```

#### Script-2 -- SCP_ConvertTaskTimeFile.R

This script checks the taskTimes Rdata file for errors such as when the same visit numbers span different dates and same dates span different visit numbers
and logs them into the Logs folder. After execution of this script, two csv files are generated storing the errors. Please check them and change them manually
in the taskTimes csv file and re-run the Script-1. SCP_ConvertTaskTimeFile.R again.

Before execution of this script, Please open the file and set the parameters in the Parameters settings section as per the instructions in the 
script file::

```
	
#Set the working directory to the location where the scripts and function R files are located 
setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Set the full path of the tasktime Rdata file
TASKTIMESFILENAME <- "~/Desktop/Data_Mining_Project/Raw_Data/taskTimes_all.Rdata"

#Set the folder of the log file
LOGFILESFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Logs/"


``` 

#### Script-3 -- SCP_CreateAccelerometerDataSubset.R

This script creates subset of the raw accelerometer data based on the start and the end time range for a given task for a participant 
and it creates individual subset files for each participant in the Original_SubSet folder.

Before execution of this script, Please open the file and set the parameters in the Parameters settings section as per the instructions in the 
script file::

```
	
#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Load the Function R Files
source("FUN_Create_Subset_Accelerometer_Data_Files.R")

#Set the full path of the tasktime Rdata file
TASKTIMESFILENAME <- "~/Desktop/Data_Mining_Project/Raw_Data/taskTimes_all.Rdata"

``` 

#### Script-4 -- SCP_DownSampleData_AllParticipants.R

This script downsamples the subset data of each participant from 30 Hz, 80 Hz & 100 Hz to 10 Hz in order to minimise the high frequency noise
and saves it into individual Rdata files in the Downsampled_Files folder.

Before execution of this script, Please open the file and set the parameters in the Parameters settings section as per the instructions in the 
script file::

```
	
#Set the working directory to the location where the scripts and function R files are located 
setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

# This is the address of the folder in your computer where participants' accelerometer files are located.
DATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/"

```

#### Script-5 -- SCP_Split_Train_Test_Participants.R

This script splits the subset and the downsampled data files into Training and Testing Set and moves them into their respective folders within 
Original_SubSet and Downsampled_Files folders respectively.

Before execution of this script, Please open the file and set the parameters in the Parameters settings section as per the instructions in the 
script file::

```
#Set the working directory to the location where the scripts and function R files are located 
setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Set the full path of the tasktime Rdata file
TASKTIMESFILENAME <- "~/Desktop/Data_Mining_Project/Raw_Data/taskTimes_all.Rdata"

#Set the folder of the log file
LOGFILEFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Logs/"

#Original and Downsampled Data Directories
DOWNSAMPLEDATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Downsampled_Files/"
ORIGINALDATAFOLDER <-  "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Original_SubSet/"

#Set the Number of Test Set
TESTSETSIZE = 20

```

The scripts 1 to 5 are common for any model which is a part of this project but from script 6 onwards, it is specific to the Bag of Words model.
Please execute Script 1 to Script 5 before going to the Script 6.


#### Script-6 -- SCP_1_Create_Subsequences_AllParticipants.R

This script generates the sub-sequences (3 seconds  or 6 seconds) from the downsampled data files and saves it into individual Rdata files for each participant.
The output files are stored in the respective folders under BOW_Files folder.


Before execution of this script, Please open the file and set the parameters in the Parameters settings section as per the instructions in the 
script file::

```
#Set the working directory to the location where the scripts and function R files are located 
setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Uncomment the following line and Set selected downsampled filenames when the script needs to be executed (This is line 28 in the script file)
#filelist <- as.factor("ADMC021_downsampled_Data.Rdata")

#Set CHUNKSIZE = (3 or 6) and FILETYPE = (Training_Set or Testing_Set)
CHUNKSIZE <- 3
FILETYPE <- "Testing_Set"

# This is the address of the folder in your computer where participants' accelerometer files are located.
DATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/"

#Comment the following line in case only specific files need to be executed (This is line 59 in the script file)
filelist <- dir(paste(DATAFOLDER,FILEDIR,sep=""), pattern = "^*.*Rdata$")

```

#### Script-7 -- SCP_2_Merge_All_Subsequences.R

This script merges all the sub-sequences (3s or 6s) from the individual Rdata files and saves it in a single file in the BOW_Files folder.
Please note that there are 4 training files and 2 testing files created based on the user parameter input(3s or 6s).

Before execution of this script, Please open the file and set the parameters in the Parameters settings section as per the instructions in the 
script file:

```
#Set the working directory to the location where the scripts and function R files are located 
setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Set the directory to the location where the subsequence files are present
DATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/BOW_Files/"

#Set FILETYPE = (Training_Set or Testing_Set) and CHUNKSIZE = (3 or 6).
CHUNKSIZE=3
FILETYPE <- "Testing_Set"

```

#### Script-8 -- SCP_3_Generate_CodeBook.R

This script generates the codebook for 3s and 6s subsequences of the training set by using spark cluster framework using k-means clustering technique.
If there are library issues executing this script, please ensure that the sparklyr library is correctly installed since it is required to initiate the 
Apache Spark Framework.

Before execution of this script, Please open the file and set the parameters in the Parameters settings section as per the instructions in the 
script file:

```
#Set the working directory to the location where the scripts and function R files are located 
setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Set the directory to the location where the subsequence files are present
ALLCHUNKSFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/BOW_Files/"

#Set the directory where the codebook.df would be stored
CODEBOOKFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Cleaned_Data/"

#Set CHUNKSIZE = 3 or 6
CHUNKSIZE=3

```

#### Script-9 -- SCP_4_Generate_Word_Labels.R

This script generates the BOW labels for 3s and 6s subsequences of the data based on the codebook values and dynamic time warping (DTW) technique.
If there are library issues executing this script, please ensure that the dtw library is correctly installed since it is required 
for dynamic time warping (DTW) technique. The files are created in the D32 or D64 folders under Cleaned_Data.

Before execution of this script, Please open the file and set the parameters in the Parameters settings section as per the instructions in the 
script file:

```
#Set the working directory to the location where the scripts and function R files are located 
setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Set the directory to the location where the merged subsequence files are present
ALLCHUNKSFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/BOW_Files/"

#Set the directory where the codebook is stored
CODEBOOKFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Cleaned_Data/"

#Set CHUNKSIZE = (3 or 6) and FILETYPE = (Training_Set or Testing_Set).
CHUNKSIZE <- 3
FILETYPE <- "Training_Set"

```

#### Script-10 -- SCP_5_Merge_Word_Label_Files.R

This script merges all the 3s or 6s word labels data files into a single file. Please note that 4 separate RData files are created in the Cleaned_Data
based on the user input parameters.

```

#Set the working directory to the location where the scripts and function R files are located 
setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")


#Set the directory where the cleaned data files are kept
FILEDIR = "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Cleaned_Data/"

#Set CHUNKSIZE = (3 or 6) and FILETYPE = (Training_Set or Testing_Set).
CHUNKSIZE <- 3
FILETYPE <- "Training_Set"

```

#### Script-11 -- SCP_6_Calculate_TF_IDF.R

This script calculates the term frequency and inverse doc frequency of training and testing data created by the previous script
and stores the final cleaned data files in the Cleaned_Data folder.

```
#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Set CHUNKSIZE = (3 or 6) and FILETYPE = (Training_Set or Testing_Set).
CHUNKSIZE=6
FILETYPE <- "Testing_Set"

#Set the directory where the DTW subsequnces with labels are stored
DATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Cleaned_Data/"

```
After all the data cleaning scripts have been executed in the following sequence as mentioned above, the next part is the Activity recognition classification
which is done by the following script:

### Activity Recognition Script

#### Script 1 -- SCP_Activity_Data_Classification.R

This script classifies the cleaned data into two classes based on user input. It uses four types of classifiers - SVM, DecisionTree, RandomForest and LDA.
There are two types of classification as given below :
	1. Sedentary and Non-Sedentary : 1 as Sedentary and 0 as Non-Sedentary.
	2. Locomotion and Stationary : 1 as Locomotion and 0 as Stationary. 

Some parameters have been defaulted in the functions for each classifier as it gave the best results. 
It can be changed by the user if needed. Please check the function script FUN_Activity_Data_Classifier_Functions.R
for details.
```
#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Codes/Classification/")


#Set CLASS_CATEGORY = ("Sedentary" or "Locomotion"), CHUNKSIZE = (3 or 6) 
#and CLASSIFIER_TYPE =  ("SVM" or "DecisionTree" or "RandomForest" or "LDA")

CHUNKSIZE=6
CLASS_CATEGORY <- "Locomotion"
CLASSIFIER_TYPE <- "SVM"


#Set the data directory of the Cleaned Data

DATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Cleaned_Data/"
OUTPUTFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Cleaned_Data/Model_Output"
```

This script displays the confusion matrix of the test data. If this script needs to be executed with different sets of test data. 
Then, Please execute the data cleaning tasks on each set and then run only the "Test the model" section from the script.

## Special Notes

Please check the SCP_Demo_Script.R for more details about the parameters and script execution process.
