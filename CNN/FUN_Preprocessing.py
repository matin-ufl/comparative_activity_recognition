
#Script Details ----------------------------------------------------------------------------------------------------

#Script Name : FUN_Preprocessing.py

#Script Summary : 
#   This script contains five functions
#    1. FUN_ReadCSV            : Function to read data,add PID column and select only the middle 3 minutes of each activity.
#    2. FUN_TimeToInteger      : Function to transform time from HH:MM:SS to HHMMSS.
#    3. FUN_ConvertToSedentary : Function to label activity as Sedentary or Non Sedentary
#    4. FUN_ConvertToLocomotion: Function to label activity as Locmotion or Stationary
#    5. FUN_OnlySedentary      : Function to extract only sedentary activites
#    6. FUN_OnlyLocomotion     : Function to extract only locomotion activities
#    7. FUN_Sed_Loc_Columns    : Function to add binary valued columns :- Sedentary,Locomotion,TV WATCHING,COMPUTER WORK,STANDING STILL,LEISURE WALK, RAPID WALK, WALKING AT RPE 1, WALKING AT RPE 5,STAIR ASCENT,STAIR DESCENT   
#    8. FUN_Window             : Function to determine the start and end of each segment
#    9. FUN_Segment            : Function to segment data ,where each segment consist of 100 data points
#   10. FUN_Segment_TwoStep    : Function to segment data for two step method
#   11. FUN_Segment_ThreeStep  : Function to segment data for three step method

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
from scipy import stats


#change the directory and read all csv files into a single dataframe
#selection only the middle 3 minutes of each activity
def FUN_ReadCSV(path):
    
    # Input :-
    #    1. path : Location of the data
    # Output :-
    #    1. df : Concatinate all csv files into a single data frame

    #merging all csv files into a single panda dataframe
    #changing the working directory and reading all the csv files from the csv
    os.chdir(path)
    data=pd.DataFrame()    
    filelist = [i for i in glob.glob('*.{}'.format('csv'))]
    for file in filelist:
        raw_data = pd.read_csv(file)
        file = file[:7]        
        raw_data.insert(0, "PID", file)
        activity = raw_data.TaskLabel.unique()
        for act in activity:
            data_act = raw_data.loc[raw_data['TaskLabel'] == act]
            length = len(data_act)/2
            start = length - 900
            end = length + 900
            data_act = data_act[start:end]
            data = data.append(data_act,ignore_index=False)
    return data
    
#Converting HH:MM:SS to HHMMSS
def FUN_TimeToInteger(df):

    # Input :-
    #   1. df : dataframe with a column timeOnly
    # Output :-
    #   1. df : dataframe with timeOnly column converted to an integer

    df['timeOnly'] = df['timeOnly'].str.replace(':','')
    df['timeOnly'] = pd.to_numeric(df['timeOnly'])
    return df
    
#Fucntion to convert the task label into 2 categories
def FUN_ConvertToSedentary(df):
    
    # Input :-
    #   1. df : dataframe with  "TaskLabel" column which has 33 classes
    # Output :-
    #   1. df : dataframe with "TaskLabel" column consisting of 2 classes - Sedentary(0) and NonSedentary(1)

    Sedentary_Activities = ['COMPUTER WORK','TV WATCHING','STANDING STILL']
    #Locomotive_Activities = ['LEISURE WALK','RAPID WALK','WALKING AT RPE 1','WALKING AT RPE 5','STAIR DESCENT','STAIR ASCENT']
    for i in Sedentary_Activities:
        df.loc[df['TaskLabel'] == i, 'TaskLabel'] = 0
    #for i in Locomotive_Activities:
     #   df.loc[df['TaskLabel'] == i, 'TaskLabel'] = 'Locomotion'
    Non_Sed = df.TaskLabel.unique().tolist()
    Non_Sed.remove(0)
    #Neither.remove('Locomotion')
    for i in Non_Sed:
        df.loc[df['TaskLabel'] == i, 'TaskLabel'] = 1
    return df

#Fucntion to convert the task label into 2 categories
def FUN_ConvertToLocomotion(df):
    
    # Input :-
    #   1. df : dataframe with  "TaskLabel" column which has 33 classes
    # Output :-
    #   1. df : dataframe with "TaskLabel" column consisting of 2 classes - Locmotion(0) and Stationary(1)

    #Sedentary_Activities = ['COMPUTER WORK','TV WATCHING','STANDING STILL']
    Locomotive_Activities = ['LEISURE WALK','RAPID WALK','WALKING AT RPE 1','WALKING AT RPE 5','STAIR DESCENT','STAIR ASCENT']
    #for i in Sedentary_Activities:
     #   df.loc[df['TaskLabel'] == i, 'TaskLabel'] = 'Sedentary'
    for i in Locomotive_Activities:
        df.loc[df['TaskLabel'] == i, 'TaskLabel'] = 0
    Stationary = df.TaskLabel.unique().tolist()
    #Neither.remove('Sedentary')
    Stationary.remove(0)
    for i in Stationary:
        df.loc[df['TaskLabel'] == i, 'TaskLabel'] = 1
    return df

#Function to get data containing sedentary activities
def FUN_OnlySedentary(df):
    
    # Input :-
    #   1. df : dataframe consisting of differnet activities
    # Output :-
    #   1. df : dataframe consisting of only sedentary activites

    Sedentary_Activities = ['COMPUTER WORK','TV WATCHING','STANDING STILL']
    sed = pd.DataFrame()
    for i in Sedentary_Activities:
        temp = df.loc[df['TaskLabel'] == i]
        sed = sed.append(temp)
    return sed

#Function to get data containing locomotion activities
def FUN_OnlyLocomotion(df):
        
    # Input :-
    #   1. df : dataframe consisting of differnet activities
    # Output :-
    #   1. df : dataframe consisting of only locomotion activites

    Locomotive_Activities = ['LEISURE WALK','RAPID WALK','WALKING AT RPE 1','WALKING AT RPE 5','STAIR DESCENT','STAIR ASCENT']
    loco = pd.DataFrame()
    for i in Locomotive_Activities:
        temp = df.loc[df['TaskLabel'] == i]
        loco = loco.append(temp)
    return loco
    
#add locomotion and sedentary cols   
def FUN_Sed_Loc_Columns(df):
    
    # Input :-
    #   1. df : dataframe 
    # Output :-
    #   1. df : dataframe with 11 additional columns

    New_columns = ['Sedentary','Locomotion','COMPUTER WORK','TV WATCHING','STANDING STILL','LEISURE WALK','RAPID WALK','WALKING AT RPE 1','WALKING AT RPE 5','STAIR DESCENT','STAIR ASCENT']
    for i in New_columns:
        df[i] = 0
    
    df.loc[df['TaskLabel']=='STANDING STILL',"Sedentary"] = 1
    df.loc[df['TaskLabel']=='STANDING STILL',"STANDING STILL"] = 1

    df.loc[df['TaskLabel']=='COMPUTER WORK',"Sedentary"] = 1
    df.loc[df['TaskLabel']=='COMPUTER WORK',"COMPUTER WORK"] = 1
    
    df.loc[df['TaskLabel']=='TV WATCHING',"Sedentary"] = 1
    df.loc[df['TaskLabel']=='TV WATCHING',"TV WATCHING"] = 1
    
    df.loc[df['TaskLabel']=='LEISURE WALK',"Locomotion"] = 1
    df.loc[df['TaskLabel']=='RAPID WALK',"Locomotion"] = 1    
    df.loc[df['TaskLabel']=='WALKING AT RPE 1',"Locomotion"] = 1
    df.loc[df['TaskLabel']=='WALKING AT RPE 5',"Locomotion"] = 1
    df.loc[df['TaskLabel']=='STAIR ASCENT',"Locomotion"] = 1
    df.loc[df['TaskLabel']=='STAIR DESCENT',"Locomotion"] = 1
    
    df.loc[df['TaskLabel']=='LEISURE WALK',"LEISURE WALK"] = 1
    df.loc[df['TaskLabel']=='RAPID WALK',"RAPID WALK"] = 1    
    df.loc[df['TaskLabel']=='WALKING AT RPE 1',"WALKING AT RPE 1"] = 1
    df.loc[df['TaskLabel']=='WALKING AT RPE 5',"WALKING AT RPE 5"] = 1
    df.loc[df['TaskLabel']=='STAIR ASCENT',"STAIR ASCENT"] = 1
    df.loc[df['TaskLabel']=='STAIR DESCENT',"STAIR DESCENT"] = 1
    return df
    
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
        start += size 

#Making segments in the data (select the dataframe and the length of segments)
#For one step
def FUN_Segment(df,window_size):

    # Input :-
    #   1. df : Time Series DataFrame which is to be segmented
    #   2. size : Length of each segment
    # Output :-
    #   1. segments : Data frame consisting of 3 columns representing the X,Y and Z axis
    #   2. met : Data frame consisting of  met types
    #   3. labels : Data frame consisting of  activity types
    segments = np.empty((0,window_size,3))
    labels = np.empty((0))
    met = np.empty((0))
    #Segemts are determined using the "timeOnly" column of the time series data
    for (start, end) in FUN_Window(df['timeOnly'], window_size):
        x = df["X"][start:end]
        y = df["Y"][start:end]
        z = df["Z"][start:end]
        if(len(df['timeOnly'][start:end]) == window_size):
            met = np.append(met,stats.mode(df["METs"][start:end])[0][0])
            segments = np.vstack([segments,np.dstack([x,y,z])])
            labels = np.append(labels,stats.mode(df["TaskLabel"][start:end])[0][0])
    return segments, met , labels

#Making segments in data with sedentary and locmotion columns
def FUN_Segment_TwoStep(df,window_size):

    # Input :-
    #   1. df : Time Series DataFrame which is to be segmented
    #   2. size : Length of each segment
    # Output :-
    #   1. segments : Data frame consisting of 5 columns representing the X,Y,Z,Sedentary and Locomotion
    #   2. met : Data frame consisting of  met types
    #   3. labels : Data frame consisting of  activity types

    segments = np.empty((0,window_size,12))
    labels = np.empty((0))
    met = np.empty((0))
    #Segemts are determined using the "timeOnly" column of the time series data
    for (start, end) in FUN_Window(df['timeOnly'], window_size):
        x = df["X"][start:end]
        y = df["Y"][start:end]
        z = df["Z"][start:end]
        sed = df["Sedentary"][start:end]
        loco = df["Locomotion"][start:end]
        if(len(df['timeOnly'][start:end]) == window_size):
            met = np.append(met,stats.mode(df["METs"][start:end])[0][0])
            met = np.append(met,stats.mode(df["METs"][start:end])[0][0])
            met = np.append(met,stats.mode(df["METs"][start:end])[0][0])
            segments = np.vstack([segments,np.dstack([[x,y,z],[sed,sed,sed],[loco,loco,loco]])])
            labels = np.append(labels,stats.mode(df["TaskLabel"][start:end])[0][0])
    return segments, met , labels
    
#Making segments in data with sedentary,locomotion as well each of the 9 activities
def FUN_Segment_ThreeStep(df,window_size):

    # Input :-
    #   1. df : Time Series DataFrame which is to be segmented
    #   2. size : Length of each segment
    # Output :-
    #   1. segments : Data frame consisting of 14 columns 
    #   2. met : Data frame consisting of  met types
    #   3. labels : Data frame consisting of  activity types

    segments = np.empty((0,window_size,12))
    labels = np.empty((0))
    met = np.empty((0))
    #Segemts are determined using the "timeOnly" column of the time series data
    for (start, end) in FUN_Window(df['timeOnly'], window_size):
        x = df["X"][start:end]
        y = df["Y"][start:end]
        z = df["Z"][start:end]
        sed = df["Sedentary"][start:end]
        loco = df["Locomotion"][start:end]
        tv =  df["TV WATCHING"][start:end]
        cw = df["COMPUTER WORK"][start:end]
        st = df["STANDING STILL"][start:end]
        lw = df["LEISURE WALK"][start:end]
        rw = df["RAPID WALK"][start:end]
        w1 = df["WALKING AT RPE 1"][start:end]
        w5 = df["WALKING AT RPE 5"][start:end]
        sa = df["STAIR ASCENT"][start:end]
        sd = df["STAIR DESCENT"][start:end]
        if(len(df['timeOnly'][start:end]) == window_size):
            met = np.append(met,stats.mode(df["METs"][start:end])[0][0])
            met = np.append(met,stats.mode(df["METs"][start:end])[0][0])
            met = np.append(met,stats.mode(df["METs"][start:end])[0][0])
            segments = np.vstack([segments,np.dstack([[x,y,z],[sed,sed,sed],[loco,loco,loco],[tv,tv,tv],[cw,cw,cw],[st,st,st],[lw,lw,lw],[rw,rw,rw],[w1,w1,w1],[w5,w5,w5],[sa,sa,sa],[sd,sd,sd]])])
            labels = np.append(labels,stats.mode(df["TaskLabel"][start:end])[0][0])
    return segments, met , labels