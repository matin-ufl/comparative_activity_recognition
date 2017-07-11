
#Script Details ----------------------------------------------------------------------------------------------------

#Script Name : FUN_Preprocessing.py

#Script Summary : 
#   This script contains five functions
#    1. FUN_ReadCSV         : Function to read data from training and testing set.
#    2. FUN_TimeToInteger   : Function to transform time from HH:MM:SS to HHMMSS.
#    3. FUN_ConvertTO3Class :Function to label activity as Sedentary,Locomotion or Neither.
#    4. FUN_Window          :Function to choose staring and ending point for generating segments
#    5. FUN_Segment         :Function to generate segment

#Author & Reviewer Details ------------------------------------------------------------------------------------------

#Author : Abhijay Gupta
#Date : 07/11/2017
#E-Mail : abhijayvgupta@gmail.com
#Reviewed By : 
#Review Date : 
#Reviewer E-Mail : 



#import libraries to read data
import glob,os
import pandas as pd
import numpy as np



#change the directory and read all csv files into a single dataframe
def FUN_ReadCSV(path):

    # Input :-
    #    1. path : Location of the data
    # Output :-
    #    1. df : Concatinate all csv files into a single data frame

    #merging all csv files into a single panda dataframe
    #changing the working directory and reading all the csv files from the csv
    os.chdir(path)
    filelist = [i for i in glob.glob('*.{}'.format('csv'))]
    df_list = [pd.read_csv(file) for file in filelist]
    df = pd.concat(df_list)
    return df



#Converting HH:MM:SS to HHMMSS
def FUN_TimeToInteger(df):

    # Input :-
    #   1. df : dataframe with a column timeOnly
    # Output :-
    #   1. df : dataframe with timeOnly column converted to an integer

    df['timeOnly'] = df['timeOnly'].str.replace(':','')
    df['timeOnly'] = pd.to_numeric(df['timeOnly'])
    return df
    
#Fucntion to convert the task label into 3 categories
#Locomotion Sedentary Neither
def FUN_ConvertTo3Class(df):
    
    # Input :-
    #   1. df : dataframe with  "TaskLabel" column which has 33 classes
    # Output :-
    #   1. df : dataframe with "TaskLabel" column consisting of 3 classes

    Sedentary_Activities = ['COMPUTER WORK','TV WATCHING','STANDING STILL']
    Locomotive_Activities = ['LEISURE WALK','RAPID WALK','WALKING AT RPE 1','WALKING AT RPE 5','STAIR DESCENT','STAIR ASCENT']
    for i in sed:
        df.loc[df['TaskLabel'] == i, 'TaskLabel'] = 'Sedentary'
    for i in loc:
        df.loc[df['TaskLabel'] == i, 'TaskLabel'] = 'Locomotion'
    Neither = df.TaskLabel.unique().tolist()
    neither.remove('Sedentary')
    neither.remove('Locomotion')
    for i in neither:
        df.loc[df['TaskLabel'] == i, 'TaskLabel'] = 'Neither'
    return df


#Selecting starting and ending data points from time series data
def FUN_Window(df, size):

    # Input :-
    #   1. df : Time Series DataFrame whose segments starting and ending point is to be determined
    #   2. size : Length of each segment
    # Output :-
    #   1. start : The starting point of the segment
    #   2. start+size : The ending point of the segment
    start = 0
    while start < df.count():
        yield start, start + size
        start += (size / 2)

#Making segments in the data (select the dataframe and the length of segments)
def FUN_Segment(df,window_size):

    # Input :-
    #   1. df : Time Series DataFrame which is to be segmented
    #   2. size : Length of each segment
    # Output :-
    #   1. segments : Data frame consisting of 3 columns representing the X,Y and Z axis
    #   2. labels : Data frame consisting of  activity types
    
    segments = np.empty((0,window_size,3))
    labels = np.empty((0))
    #Segemts are determined using the "timeOnly" column of the time series data
    for (start, end) in FUN_Window(df['timeOnly'], window_size):
        x = df["X"][start:end]
        y = df["Y"][start:end]
        z = df["Z"][start:end]
        if(len(df['timeOnly'][start:end]) == window_size):
            segments = np.vstack([segments,np.dstack([x,y,z])])
            labels = np.append(labels,stats.mode(df["TaskLabel"][start:end])[0][0])
    return segments, labels

