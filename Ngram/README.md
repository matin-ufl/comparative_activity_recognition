# Ngram approach for Activity Recognition

This project is used to classify various day to day activities (like TV watching, Walking, Standing etc.) into two different categories. One category is Sedentary and Non-Sedentary. The other is the Locomotion and Stationary. The objective of this project is to read and analyze the raw accelerometer data of 146 participants and predict the type of activities that they were doing. The prediction task is done by generating ngram based features for training and test data. The classifiers are trained using features for 126 participants. The rest of the 20 participants’ features is the testing data which is used to check the accuracy of the activity prediction of the classifiers.

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

1.	data.table
2.	dplyr
3.	pbapply
4.	sparklyr
5.	e1071
6.	rpart
7.	randomForest
8.	caret
9.	reshape2

Run the following commands to install the libraries:

```
install.packages("data.table")
install.packages("dplyr")
install.packages("pbapply")
install.packages("sparklyr")
install.packages("e1071")
install.packages("rpart")
install.packages("randomForest")
install.packages("caret")
install.packages("reshape2")
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
library(reshape2)

```

### Prerequisite Folder Structure

Create a folder Raw_Data and place the tasktimes csv file in it.

Then, create a new folder Participant_Data inside Raw_Data folder and store the raw accelerometer data folders for each participant in this folder.

Then, Inside Participant_Data Folder create the following directory and sub-directory structure :

i)	Original_SubSet |-> Training_Set |-> nGram_Files
    Original_SubSet |-> Testing_Set |-> nGram_Files
ii)	Downsampled_Files |-> Training_Set |-> nGram_Files
    Downsampled_Files |-> Testing_Set |-> nGram_Files
iii)Logs
                              
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

The scripts 1 to 5 are common for any of the approaches used in this project. From following script 6 onwards, it is specific to the Ngram approach. Please execute Script 1 to Script 5 before going to the Script 6.

### Feature Construction Script

#### Script-6 – Ngram / Data Cleaning / SCP_Master_Script.R

This script constructs unigram and bigram features and saves the corresponding feature data files. The output files are stored in the respective dataset folder under the nGram_Files folder.

Before execution of this script, please open the file and set the parameters in the Parameters settings section as per the instructions in the script file:

```
#Set the full path where participants' Rdata files are located
DATAFOLDER <- "C:/Users/shikh/Documents/University of Florida/Activity Recognition/Raw Data/Participant Data/Training_Set/"

#Set the number of bins to use for binning participant data
NUMBEROFBINS <- 10

#Set the working directory to the location where the scripts and function R files are located
setwd("C:/Users/shikh/Documents/University of Florida/Activity Recognition/DataCleanUp")

```

After the above script has been executed, the next part is the Activity recognition classification which is done by the following script:

### Activity Recognition Script

#### Script 7 -- Ngram / Classification /SCP_Master_Script.R

This script classifies the cleaned data into two classes based on user input. It uses three types of classifiers - SVM, Naive Bayes, Random Forest.
There are two types of classification as given below :
	1. Sedentary and Non-sedentary : 1 as Sedentary and 0 as Non-sedentary.
	2. Locomotion and Stationary : 1 as Locomotion and 0 as Stationary. 

Some parameters have been defaulted in the functions for each classifier as it gave the best results. 
It can be changed by the user if needed. Please check the function script FUN_Activity_Data_Classifier_Functions.R
for details.

```
#Set the working directory to the location where the scripts and function R files are located
setwd("C:/Users/shikh/Documents/University of Florida/Activity Recognition/Classification/")

#Set the full path where training set Rdata file is located
TRAININGDATAFOLDER <- "C:/Users/shikh/Documents/University of Florida/Activity Recognition/Raw Data/Participant Data/Training_Set/nGram_Files/"

#Set the full path where test set Rdata file is located
TESTINGDATAFOLDER <- "C:/Users/shikh/Documents/University of Florida/Activity Recognition/Raw Data/Participant Data/Testing_Set/nGram_Files/"

#Set the type of nGram features to use (Unigrams/Bigrams)
NGRAMTYPE <- "Unigrams"

```

This script displays the Precision, Recall and F1-Score metrics of the test data. If the confusion matrix for the data needs to be viewed, please uncomment the relevant sections from the following script.

```
#### Script 8 -- Ngram / Classification /SCP_Master_Script.R

To view the confusion matrix for a specific classifier, please uncomment below sections from the body of the classifier function.

#---Uncomment following section to view the confusion matrix for Sedentary data---#
#confusion.matrix.sedentary <- FUN_getResults(svm.predicted,testing.df$class.sedentary)[[1]]
#View(confusion.matrix.sedentary)
#---------------------------------------------------------------------------------#

#---Uncomment following section to view the confusion matrix for Locomotion data---# #confusion.matrix.locomotion <- FUN_getResults(svm.predicted,testing.df$class.locomotion)[[1]]
#View(confusion.matrix.locomotion)
#----------------------------------------------------------------------------------#

```
