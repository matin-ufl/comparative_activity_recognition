#Script Details -------------------------------------------------------------------------------------

#Script Name : FUN_Activity_Data_Classifier_Functions.R

#Script Summary : 
#       This script contains three functions required for TF-IDF Calculations.
#         1. FUN_Add_SDNT_TaskLabels : Function to add Sedentary/Non-Sedentary task labels.
#         2. FUN_Add_LCM_TaskLabels : Function to add Locomotion/Stationary task labels.
#         3. FUN_SDNT_Train_Classifier : Function to train Sedentary/Non-Sedentary Classifier.
#         4. FUN_LCM_Train_Classifier : Function to train Locomotion/Stationary Classifier.
#         5. FUN_Evaluate_Classifier : Function to predict test data.
#         6. FUN_Display_Classifier_Stats : Function to display the prediction statistics of test data.

#Author & Reviewer Details --------------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/14/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date :
#Reviewer E-Mail : hiranava@ufl.edu

#FUN_Add_SDNT_TaskLabels

FUN_Add_SDNT_TaskLabels <- function(train.df) {
  
  # Input :- train.df : This dataframe contains the feature variables of the training set.
  # Output :- train.df : This dataframe contains the sedentary task labels added to the input dataframe.
  
  #List of Sedentary Tasks
  
  sedentarytasklist <- c("STANDING STILL", "TV WATCHING", "COMPUTER WORK")
  
  #Add Task Label for Sedentary/ Non-Sedentary Task
  
  train.df$TaskLabel <- sapply(c(train.df$Task), function(x) {ifelse(any(x %in% sedentarytasklist),1, 0)})
  
  return (train.df)
  
}

#FUN_Add_LCM_TaskLabels

FUN_Add_LCM_TaskLabels <- function(train.df) {
  
  # Input :- train.df : This dataframe contains the feature variables of the training set.
  # Output :- train.df : This dataframe contains the locomotion task labels added to the input dataframe.
  
  #List of Sedentary Tasks
  
  locomotiontasklist <- c("WALKING AT RPE 1", "WALKING AT RPE 5", "STAIR DESCENT", "STAIR ASCENT", 
                          "LEISURE WALK","RAPID WALK")
  
  #Add Task Label for Sedentary/ Non-Sedentary Task
  
  train.df$TaskLabel <- sapply(c(train.df$Task), function(x) {ifelse(any(x %in% locomotiontasklist),1, 0)})
  
  return (train.df)
  
}

#FUN_SDNT_Train_Classifier

#Load the libraries
library(e1071)  #SVM
library(rpart)  #Decision Trees
library(randomForest) #Random Forest
library(MASS) #LDA

FUN_SDNT_Train_Classifier <- function(train.df, classifier_type , chunk_size, 
                                      cost_val = 100, gamma_val = 1, svm_kernel = "radial", 
                                      kernel_flag = TRUE, d_tree_method = "class", rf_ntree = 5000) {
  
  # Input :- train.df : This dataframe contains the feature variables with sedentary task labels of the training set.
  #          classifier_type : This variable stores the classifier type (SVM/DecisionTree/RandomForest/LDA).
  #          chunk_size : This varaible stores the sub-sequence type (3s or 6s).
  #          cost_val : This is the cost value for SVM classifier. Defaulted to 100 for best results.
  #          gamma_val : This is the gamma value for SVM classifier. Defaulted to 1 for best results.
  #          svm_kernel : This is the kernel value for SVM classifier ("linear", "radial" or "polynomial").
  #                       Defaulted to "radial" for best results. 
  #          kernel_flag : This is the kernel flag value for SVM classifier ("TRUE" or "FALSE"). 
  #                        Defaulted to TRUE for best results. 
  #          d_tree_method : This is the method value for Decision Tree classifier ("anova", "poisson", "class" or "exp").
  #                          Defaulted to "class" since it is a classification problem.  
  #          rf_ntree : This is the number of trees for Random Forest classifier. 
  #                     Defaulted to 5000 for best results.  
  # Output :- model : This stores the trained model for the sedentary classifier.
  
  if(classifier_type == "SVM") {
    
    #Train the SVM Classifier
    
    model <- svm(x = train.df[,startsWith(colnames(train.df), "D")], y = as.factor(train.df$TaskLabel), 
                 cost = cost_val, 
                 gamma = gamma_val, 
                 kernel = svm_kernel, usekernel = kernel_flag)
    
  } else  if(classifier_type == "DecisionTree") {
    
    if(chunk_size == 3) {
      
      #Train the Decision Tree Classifier
      
      model <- rpart(TaskLabel ~ D1+D2+D3+D4+D5+D6+D7+D8+D9+D10+D11+D12+D13+D14+D15+D16+
                     D17+D18+D19+D20+D21+D22+D23+D24+D25+D26+D27+D28+D29+D30+D31+D32, 
                     train.df,method = d_tree_method)
      
      
    } else if (chunk_size == 6) {
      
      #Train the Decision Tree Classifier
      
      model <- rpart(TaskLabel ~ D1+D2+D3+D4+D5+D6+D7+D8+D9+D10+D11+D12+D13+D14+D15+D16+
                       D17+D18+D19+D20+D21+D22+D23+D24+D25+D26+D27+D28+D29+D30+D31+D32+
                       D33+D34+D35+D36+D37+D38+D39+D40+D41+D42+D43+D44+D45+D46+D47+D48+
                       D49+D50+D51+D52+D53+D54+D55+D56+D57+D58+D59+D60+D61+D62+D63+D64, 
                     train.df,method = d_tree_method)
      
    }
    
    
  } else  if(classifier_type == "RandomForest") {
    
     #Set the number of tries based on chunk size
    
      if (chunk_size==3) {
        
        NTRY <-sqrt(32);
        
      } else if (chunk_size==6) {
        
        NTRY <-sqrt(64);
      
      }
    
      #Train the Random Forest Classifier 
      model <- randomForest(x = train.df[,startsWith(colnames(train.df), "D")], y = as.factor(train.df$TaskLabel)
                            ,ntree = rf_ntree, mtry = NTRY)
      
    
  } else  if(classifier_type == "LDA") {
    
    if(chunk_size == 3) {
      
      #Train the LDA Classifier
      
      model <- lda(TaskLabel ~ D1+D2+D3+D4+D5+D6+D7+D8+D9+D10+D11+D12+D13+D14+D15+D16+
                       D17+D18+D19+D20+D21+D22+D23+D24+D25+D26+D27+D28+D29+D30+D31+D32, 
                     train.df)
      
      
    } else if (chunk_size == 6) {
      
      #Train the LDA Classifier
      
      model <- lda(TaskLabel ~ D1+D2+D3+D4+D5+D6+D7+D8+D9+D10+D11+D12+D13+D14+D15+D16+
                       D17+D18+D19+D20+D21+D22+D23+D24+D25+D26+D27+D28+D29+D30+D31+D32+
                       D33+D34+D35+D36+D37+D38+D39+D40+D41+D42+D43+D44+D45+D46+D47+D48+
                       D49+D50+D51+D52+D53+D54+D55+D56+D57+D58+D59+D60+D61+D62+D63+D64, 
                     train.df)
      
    }
    
  } 
  
  return(model)
}

#FUN_LCM_Train_Classifier

FUN_LCM_Train_Classifier <- function(train.df, classifier_type , chunk_size, 
                                     cost_val = 0.1, gamma_val = 0.5, svm_kernel = "polynomial", 
                                     kernel_flag = TRUE, d_tree_method = "class", rf_ntree = 5000) {
  
  # Input :- train.df : This dataframe contains the feature variables with locomotion task labels of the training set.
  #          classifier_type : This variable stores the classifier type (SVM/DecisionTree/RandomForest/LDA).
  #          chunk_size : This varaible stores the sub-sequence type (3s or 6s).
  #          cost_val : This is the cost value for SVM classifier. Defaulted to 0.1 for best results.
  #          gamma_val : This is the gamma value for SVM classifier. Defaulted to 0.5 for best results.
  #          svm_kernel : This is the kernel value for SVM classifier ("linear", "radial" or "polynomial").
  #                       Defaulted to "polynomial" for best results. 
  #          kernel_flag : This is the kernel flag value for SVM classifier ("TRUE" or "FALSE"). 
  #                        Defaulted to TRUE for best results. 
  #          d_tree_method : This is the method value for Decision Tree classifier ("anova", "poisson", "class" or "exp").
  #                          Defaulted to "class" since it is a classification problem.  
  #          rf_ntree : This is the number of trees for Random Forest classifier. 
  #                     Defaulted to 5000 for best results.  
  # Output :- model : This stores the trained model for the locomotion classifier.
  
  if(classifier_type == "SVM") {
    
    #Train the SVM Classifier
    
    model <- svm(x = train.df[,startsWith(colnames(train.df), "D")], y = as.factor(train.df$TaskLabel), 
                 cost = cost_val,  
                 gamma = gamma_val, 
                 kernel = svm_kernel, usekernel = kernel_flag)
    
  } else  if(classifier_type == "DecisionTree") {
    
    if(chunk_size == 3) {
      
      #Train the Decision Tree Classifier
      
      model <- rpart(TaskLabel ~ D1+D2+D3+D4+D5+D6+D7+D8+D9+D10+D11+D12+D13+D14+D15+D16+
                     D17+D18+D19+D20+D21+D22+D23+D24+D25+D26+D27+D28+D29+D30+D31+D32, 
                     train.df,method = d_tree_method)
      
      
    } else if (chunk_size == 6) {
      
      #Train the Decision Tree Classifier
      
      model <- rpart(TaskLabel ~ D1+D2+D3+D4+D5+D6+D7+D8+D9+D10+D11+D12+D13+D14+D15+D16+
                       D17+D18+D19+D20+D21+D22+D23+D24+D25+D26+D27+D28+D29+D30+D31+D32+
                       D33+D34+D35+D36+D37+D38+D39+D40+D41+D42+D43+D44+D45+D46+D47+D48+
                       D49+D50+D51+D52+D53+D54+D55+D56+D57+D58+D59+D60+D61+D62+D63+D64 , 
                     train.df,method = d_tree_method)
      
    }

    
  } else  if(classifier_type == "RandomForest") {
    
    #Set the number of tries based on chunk size
    
    if (chunk_size==3) {
      
      NTRY <-sqrt(32);
      
    } else if (chunk_size==6) {
      
      NTRY <-sqrt(64);
      
    }
    
      #Train the Random Forest Classifier 
      model <- randomForest(x = train.df[,startsWith(colnames(train.df), "D")], y = as.factor(train.df$TaskLabel)
                            ,ntree = rf_ntree, mtry = NTRY)
      
      
  } else  if(classifier_type == "LDA") {
  
    if(chunk_size == 3) {
      
      #Train the LDA Classifier
      
      model <- lda(TaskLabel ~ D1+D2+D3+D4+D5+D6+D7+D8+D9+D10+D11+D12+D13+D14+D15+D16+
                     D17+D18+D19+D20+D21+D22+D23+D24+D25+D26+D27+D28+D29+D30+D31+D32, 
                   train.df)
      
      
    } else if (chunk_size == 6) {
      
      #Train the LDA Classifier
      
      model <- lda(TaskLabel ~ D1+D2+D3+D4+D5+D6+D7+D8+D9+D10+D11+D12+D13+D14+D15+D16+
                     D17+D18+D19+D20+D21+D22+D23+D24+D25+D26+D27+D28+D29+D30+D31+D32+
                     D33+D34+D35+D36+D37+D38+D39+D40+D41+D42+D43+D44+D45+D46+D47+D48+
                     D49+D50+D51+D52+D53+D54+D55+D56+D57+D58+D59+D60+D61+D62+D63+D64, 
                   train.df)
      
    }
  
  } 
  
  return(model)
}

#FUN_Evaluate_Classifier

FUN_Evaluate_Classifier <- function(model,test.df,classifier_type = "RandomForest") {
  
  # Input :- model : This stores the trained model for the sedentary classifier.
  #          test.df : This dataframe test set to be used for prediction.
  #          classifier_type : This variable stores the classifier type (SVM/DecisionTree/RandomForest/LDA).
  # Output :- test.df : This dataframe stores the added prediction labels to the test data input dataframe.
  
  
  #Predict Task Labels for test data set

  if (classifier_type == "LDA")
  {
    PredTaskLabel <- predict(model, test.df[,startsWith(colnames(test.df), "D")])$class
    
  } else {
    
    PredTaskLabel <- predict(model, test.df[,startsWith(colnames(test.df), "D")], type = "class")
  }

  #Add the predicted task labels to the original test dataframe
  
  test.df$PredTaskLabel <- PredTaskLabel
  
  return(test.df)
  
}

#FUN_Display_Classifier_Stats

library(caret)

FUN_Display_Classifier_Stats <- function(test.df) {
  
  # Input :- test.df : This dataframe test set to be used for prediction.
  # Output :- cf : This variable stores the confusion matrix of the test dataframe.
  
  #Print the confusion matrix of the test data
  cf <- confusionMatrix(test.df$PredTaskLabel, test.df$TaskLabel)
  
  return(cf)
  
}

