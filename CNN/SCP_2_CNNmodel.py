
#Script Details ----------------------------------------------------------------------------------------------------

#Script Name : SCP_2_CNNmodel.py

#Script Summary : 
#   This script is used to load the preprocessed numpy ndarrays and to run the CNN model 

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

#limit gpu usage
import tensorflow as tf
from keras.backend.tensorflow_backend import set_session
config = tf.ConfigProto()
config.gpu_options.per_process_gpu_memory_fraction = 0.8
set_session(tf.Session(config=config))

#loading the numpy matrix
TrainX = np.load("/home/abhijaygupta/cnn/train_x.npy")
TrainY = np.load("/home/abhijaygupta/cnn/train_y.npy")
TestX = np.load("/home/abhijaygupta/cnn/test_x.npy")
TestY = np.load("/home/abhijaygupta/cnn/test_y.npy")


#number of segments to be trained
batch_size = train_x.shape[0]

#Number of labels
num_classes = 3

#epochs
epochs =600



#The Model
model = Sequential()

#1st convolution layer with 20 filters ,each with dimension (1,10)
model.add(Conv2D(20,(1,10),activation='relu',input_shape=(1,100,3)))
model.add(MaxPooling2D(pool_size=(1,3)))
#Dropout regularization layer to prevent overfitting
model.add(Dropout(0.25))

#2nd convolution layer with 40 filters ,each with dimension (1,5)
model.add(Conv2D(40,(1,5),padding='same',activation = 'relu'))
model.add(MaxPooling2D(pool_size = (1,3)))
#Dropout regularization layer to prevent overfitting
model.add(Dropout(0.25))

#Flatten layer
model.add(Flatten())
#Dropout regularization layer to prevent overfitting
model.add(Dropout(0.5))
model.add(Dense(600, activation='relu'))
model.add(Dense(300, activation='relu'))

model.add(Dense(300, activation='relu'))
#Dropout regularization layer to prevent overfitting
model.add(Dropout(0.5))
model.add(Dense(100 ,activation = 'relu'))

#Final output layer
model.add(Dense(num_classes, activation='softmax'))

#Compiling the model and setting up the loss function (Gradient descent optimizing algorithm)
model.compile(loss=keras.losses.categorical_crossentropy,
              optimizer="Adadelta",
              metrics=['accuracy'])

#Traing the model and then testing it with the test set
model.fit(TrainX, TrainY,
          batch_size=batch_size,
          epochs=epochs,
          verbose=1,
          validation_data=(TestX, TestY))

#Loss and accuracy on the test set
SCORE = model.evaluate(TestX, TestY, verbose=0)
print('Test loss:', SCORE[0])
print('Test accuracy:', SCORE[1])

#Saving the trained model as a h5 file
model.save("cnn_model.h5")

#The saved model can be loaded and used for testing other data 
#from keras.models import load_model
#model = load_model("cnn_model.h5")
#model.evaluate(TestX,TestY,verbose=0)


#Printing the confusion matrix
from sklearn.metrics import classification_report,confusion_matrix
y_pred = model.predict_classes(TestX)
print(y_pred)
p=model.predict_proba(TestX) # to predict probability
target_names = ['Locomotion', 'Neither', 'Sedentary']
print(classification_report(np.argmax(TestY,axis=1), y_pred,target_names=target_names))
print(confusion_matrix(np.argmax(TestY,axis=1), y_pred))
