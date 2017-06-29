import numpy as np
import glob,os
import pandas as pd
import numpy as np
from scipy import stats
from FUN_preprocessing import *

#The csv file contains the following data -> "timeOnly","X","Y","Z","TaskLabel"
#location of the csv
path1 = "/home/abhijay/activity/files/even_small_train/"

#Function call to read csv
data_df = readCSV(path1)

#Function call to convert to 3 classes Locomotion Sedentary Neither   
convertTo3Class(data_df) 

#Converting HH:MM:SS to HHMMSS
data_df['timeOnly'] = data_df['timeOnly'].str.replace(':','')
data_df['timeOnly'] = pd.to_numeric(data_df['timeOnly'])


#length of each segment
window_size = 60

#converting time series data into batches of few seconds(in this case 9sec)
# in order to feed into the neural network
segments, labels = segment_signal(data_df,window_size)

#One hot encoding of activity types
labels = np.asarray(pd.get_dummies(labels), dtype = np.int8)

#reshaping the input to a 4D tensor comprising of ->
#1 number of time series data to be trained (datapoints/window_size)
#2 width of tensor (1 because the matrice has 90 rows and 1 column)
#3 height of tensor (number of data points)
#4 depth 3 (x,y and z axis)
reshaped_segments = segments.reshape(len(segments), 1,60, 3)

#saving the data frame
np.save("/home/abhijay/activity/files/reshape.npy",reshaped_segments)
np.save("/home/abhijay/activity/files/labels.npy",labels)

#loading the numpy matrix
reshaped_segments = np.load("/home/abhijay/activity/files/reshape.npy")
labels = np.load("/home/abhijay/activity/files/labels.npy")

#splitting data into train and test
train_test_split = np.random.rand(len(reshaped_segments)) < 0.70
train_x = reshaped_segments[train_test_split]
train_y = labels[train_test_split]
test_x = reshaped_segments[~train_test_split]
test_y = labels[~train_test_split]

#using the keras library with tensorflow backend
import keras
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras import optimizers 
from keras.utils import plot_model
from keras.layers.normalization import BatchNormalization

#limit gpu usage
# import tensorflow as tf
# from keras.backend.tensorflow_backend import set_session
# config = tf.ConfigProto()
# config.gpu_options.per_process_gpu_memory_fraction = 0.6
# set_session(tf.Session(config=config))

#number of matrics to be trained
batch_size = train_x.shape[0]

#types of activities
num_classes = 3

#epochs
epochs = 50

#The Model
model = Sequential()
model.add(Conv2D(12,(1,3),activation='relu',input_shape=(1,60,3)))
model.add(MaxPooling2D(pool_size=(1,2)))
model.add(Dropout(0.25))

model.add(Flatten())
model.add(BatchNormalization())

model.add(Dense(300, activation='relu'))
model.add(BatchNormalization())

model.add(Dense(300, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(300, activation='relu'))
model.add(Dense(300, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(300, activation='relu'))
model.add(BatchNormalization())

model.add(Dense(300, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(300, activation='relu'))
model.add(Dense(300, activation='relu'))

model.add(Dense(num_classes, activation='softmax'))

adam = optimizers.Adam(lr=0.001, beta_1=0.9, beta_2=0.999, epsilon=1e-08, decay=0.0)

model.compile(loss=keras.losses.categorical_crossentropy,
              optimizer=adam,
              metrics=['accuracy'])

earlyStopping=keras.callbacks.EarlyStopping(monitor='val_loss', patience=0, verbose=0, mode='auto')

model.fit(train_x, train_y,
          batch_size=batch_size,
          epochs=epochs,
          verbose=1,
          validation_data=(test_x, test_y),callbacks = [earlyStopping])
score = model.evaluate(test_x, test_y, verbose=0)
print('Test loss:', score[0])
print('Test accuracy:', score[1])

model.save("/home/abhijay/activity/files/cnn_model.h5")
