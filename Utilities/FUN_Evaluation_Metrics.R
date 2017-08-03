# _____________________________________________
# Functions for reporting methods' performance.
#
#     Accuracy.
#     Sensitivity.
#     Precision.
#     F1-score.
# ___________
# Matin Kheirkhahan (matinkheirkhahan@ufl.edu)
# _____________________________________________


calculate.accuracy <- function(actual, predicted) {
     require(MLmetrics)
     acc <- Accuracy(y_pred = predicted, y_true = actual)
     acc
}

calculate.sensitivity <- function(actual, predicted, positive.class) {
     require(MLmetrics)
     sens <- Sensitivity(y_true = actual, y_pred = predicted, positive = positive.class)
     sens
}

calculate.precision <- function(actual, predicted, positive.class) {
     require(MLmetrics)
     prec <- Precision(y_true = actual, y_pred = predicted, positive = positive.class)
     prec
}

calculate.f1score <- function(actual, predicted, positive.class) {
     require(MLmetrics)
     f1score <- F1_Score(y_true = actual, y_pred = predicted, positive = positive.class)
     f1score
}