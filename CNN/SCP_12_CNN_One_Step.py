
#Script Details ----------------------------------------------------------------------------------------------------

#Script Name : SCP_12_CNN_One_Step.py

#Script Summary : 
#   This script is used to for MET value estimation using only accelremoter data

#Author & Reviewer Details ------------------------------------------------------------------------------------------

#Author : Abhijay Gupta
#Date : 07/11/2017
#E-Mail : abhijayvgupta@gmail.com
#Reviewed By : 
#Review Date : 
#Reviewer E-Mail : 

#Importing required libraries
import numpy as np
#using the keras library with tensorflow backend
import keras
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras import optimizers 
from keras.layers.normalization import BatchNormalization

#limit gpu usage
import tensorflow as tf
from keras.backend.tensorflow_backend import set_session
config = tf.ConfigProto()
config.gpu_options.per_process_gpu_memory_fraction = 0.8
set_session(tf.Session(config=config))

#loading the numpy matrix
TrainX = np.load("/home/abhijaygupta/cnn2/train_x.npy")
TrainY = np.load("/home/abhijaygupta/cnn2/train_y.npy")
TestX = np.load("/home/abhijaygupta/cnn2/test_x.npy")
TestY = np.load("/home/abhijaygupta/cnn2/test_y.npy")
import math


#number of segments to be trained
batch_size = TrainX.shape[0]

#epochs
epochs = 100



#The Model
model = Sequential()
model.add(Conv2D(20,(1,10),activation='relu',input_shape=(1,100,3)))
model.add(MaxPooling2D(pool_size=(1,3)))
model.add(Conv2D(40,(1,5),padding='same',activation = 'relu'))
model.add(MaxPooling2D(pool_size = (1,3)))
model.add(Flatten())
model.add(Dense(2000, activation='relu'))
#model.add(BatchNormalization(500))

model.add(Dense(1000,activation='relu'))
model.add(Dense(1))

model.compile(loss='mse', optimizer='adam',metrics = ['mae'])
#Compiling the model and setting up the loss function (Gradient descent optimizing algorithm)

#class_weight = { 0 : 10.38 , 1 : 1. }

#Traing the model and then testing it with the test set
model.fit(TrainX, TrainY,
          batch_size=batch_size,
          epochs=epochs,
          verbose=1
          
#Loss and accuracy on the test set
#Saving the trained model as a h5 file
#model.save("cnn_mod.h5")

#The saved model can be loaded and used for testing other data 
#from keras.models import load_model
#model = load_model("cnn_model.h5")
print("test y ",TestY)


from sklearn.metrics import r2_score
#Prediction on test data
y_pred = model.predict(TestX)
print("y pred",y_pred)

#RMSE value
mse_value, mae_value = model.evaluate(TestX,TestY,verbose=0)
print("RMSE",mse_value**0.5)

from sklearn.metrics import r2_score
#R^2 value
y_pred = model.predict(TestX)
print("R2",r2_score(TestY, y_pred))

#Printing the confusion matrix
from sklearn.metrics import classification_report,confusion_matrix
y_pred = model.predict(TestX)
y_pred = y_pred.flatten()
y_pred = y_pred.astype(np.int8)
#p=model.predict_proba(TestX) # to predict probability
#print(p)
#target_names = ['Sedentary', 'Non-Sedentary']
#print(classification_report(TestY, y_pred,target_names=target_names))
#print(confusion_matrix(np.argmax(Labels_Sed_Test,axis=1), y_pred))
np.save("y_pred_met.npy",y_pred)
print(y_pred)
#print(confusion_matrix(TestY, y_pred))