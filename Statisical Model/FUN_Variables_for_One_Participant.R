# ____________________________________________________
# Loads the 10Hz accelerometer data for every participants.
# The accelerometer file has the following columns:
#      1. Timestamp: a character string for mm/dd/yyyy hh:MM:ss.mmm
#      2. X: Accelerometer.X axis
#      3. Y: Accelerometer.Y axis
#      4. Z: Accelerometer.Z axis
#      5. timeOnly: a character string for hh:MM:ss (derived from Timestamp)
#      6. VM: Vector magnitude (derived from X, Y, Z)
#      7. TaskLabel: a character string indicating the task name
#
# It calculates the statistcal variables for every 15-second epochs (default length):
#     1. MVM: Mean of vector magnitude
#     2. SDVM: SD of vector magnitude
#     3. MANGLE: Mean of angle between Y (vertical axis) and VM
#     4. SDANGLE: SD of angle between Y (vertical axis) and VM
#     5. P625: Fraction of powers for frequencies between 0.6 Hz and 2.5 Hz
#     6. DF: Dominant Frequency
#     7. FPDF: Fraction of power for DF
#
# Parameters:
#     1. filename: .Rdata file to load raw (10Hz) accelerometer data
#     2. PID
#     3. Epoch Length = 15 seconds
#
# Outputs:
#     1. Clean dataset: one row per task
#     2. Clean 15-sec epoch dataset: one row per 15-sec of each task
#
# ____________________
# Matin Kheirkhahan (matinkheirkhahan@ufl.edu)
# ______________________________________________________
calculate.statistical.variables <- function(filename, PID, epoch.length = 150, return.15sec.data = FALSE) {
     require(data.table)
     source("FUN_Statistical_Variables.R")
     AC.10Hz.df <- readRDS(file = filename)
     tasks <- levels(as.factor(AC.10Hz.df$TaskLabel))
     
     stat.df <- data.frame(matrix(nrow = 0, ncol = 10)) # PID, Task, Duration, MVM, SDVM, MANGLE, SDANGLE, P625, DF, FPDF
     fifteen.sec.df <- data.frame(matrix(nrow = 0, ncol = 13)) # PID, Task, Timestamp, X, Y, Z, MVM, SDVM, MANGLE, SDANGLE, P625, DF, FPDF
     for(task in tasks) {
          task.df <- as.data.table(AC.10Hz.df[AC.10Hz.df$TaskLabel == task, ])
          result <- task.df[, ]
          result$timeOnly <- as.character(result$timeOnly)
          k <- as.vector(sapply(seq(1, ceiling(nrow(result) / epoch.length)), FUN = function(x){rep(x, epoch.length)}))
          result$k <- k[1:nrow(result)]
          result[, c("Timestamp", "X", "Y", "Z", "MVM", "SDVM", "MANGLE", "SDANGLE", "P625", "DF", "FPDF") := list(timeOnly[1], mean(X), mean(Y), mean(Z), mvm(VM), sdvm(VM), mangle(Y, VM), sdangle(Y, VM),
                                                                                                                   tryCatch(p625(VM), error = function(cond){return(NA_real_)}, finally = {}),
                                                                                                                   tryCatch(df(VM), error = function(cond){return(NA_real_)}, finally = {}),
                                                                                                                   tryCatch(fpdf(VM), error = function(cond){return(NA_real_)}, finally = {})), by = k]
          result <- result[complete.cases(result), ]
          if(nrow(result) > 0){
               result <- result[seq(1, nrow(result), by = epoch.length), ]
               fifteen.sec.df <- rbind(fifteen.sec.df,
                                       data.frame(PID = PID, Task = task,
                                                  Timestamp = as.character(result$Timestamp), X = result$X, Y = result$Y, Z = result$Z,
                                                  MVM = result$MVM, SDVM = result$SDVM, MANGLE = result$MANGLE, SDANGLE = result$SDANGLE,
                                                  P625 = result$P625, DF = result$DF, FPDF = result$FPDF))
               stat.df <- rbind(stat.df,
                                data.frame(PID = PID, Task = task,
                                           Timestamp = as.character(result$Timestamp[1]), Duration.minute = nrow(result) / 4,
                                           MVM = mean(result$MVM, na.rm = T), SDVM = mean(result$SDVM, na.rm = T),
                                           MANGLE = mean(result$MANGLE, na.rm = T), SDANGLE = mean(result$SDANGLE, na.rm = T),
                                           P625 = mean(result$P625, na.rm = T), DF = mean(result$DF, na.rm = T), FPDF = mean(result$FPDF, na.rm = T)))
          }
     }
     rm(convert.fft, df, fpdf, mangle, sdangle, mvm, sdvm, p625)
     if(return.15sec.data) {
          return(fifteen.sec.df)
     }
     stat.df
}
