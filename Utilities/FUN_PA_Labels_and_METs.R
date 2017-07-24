setwd("~/Workspaces/R workspace/Comparative Activity Recognition/Utilities/")

# __________________________________________________________ #
# For the given participant (PID) and the performed PA       #
# This function returns the energy expenditure (MET) value.  #
# ______________                                             #
# Matin Kheirkhahan (matinkheirkhahan@ufl.edu)               #
# __________________________________________________________ #
giveMETValue <- function(PID, Task) {
     cosmed.df <- readRDS("MET_values.Rdata")
     res <- NA_real_
     ppt.df <- cosmed.df[cosmed.df$PID == PID, ]
     if(nrow(ppt.df) > 0) {
          task.df <- ppt.df[ppt.df$Task == Task, ]
          if(nrow(task.df) > 0) {
               res <- task.df$METs[1]
          }
     }
     res
}


# __________________________________________________________ #
# For the given participant (PID) and the performed PA       #
# This function returns the task intensity.                  #
#           {sedentary, light, moderate, vigorous}           #
# ______________                                             #
# Matin Kheirkhahan (matinkheirkhahan@ufl.edu)               #
# __________________________________________________________ #
giveMETIntensity <- function(PID, Task) {
     cosmed.df <- readRDS("MET_values.Rdata")
     res <- NA_character_
     ppt.df <- cosmed.df[cosmed.df$PID == PID, ]
     if(nrow(ppt.df) > 0) {
          task.df <- ppt.df[ppt.df$Task == Task, ]
          if(nrow(task.df) > 0) {
               res <- task.df$MET_Intensity[1]
          }
     }
     res
}

# __________________________________________________________ #
# For the sedentary_vs_non-sedentary classification, this    #
# function identifies a PA (task) belongs to which class.    #
#                                                            #
# Sedentary PAs: Computer Work, TV Watching, Standing Still  #
# Non-sedentary PAs: the rest.                               #
# ______________                                             #
# Matin Kheirkhahan (matinkheirkhahan@ufl.edu)               #
# __________________________________________________________ #
giveClassLabel_sedentary <- function(Task) {
     res <- FALSE
     if(Task %in% c("COMPUTER WORK", "TV WATCHING", "STANDING STILL")) {
          res <- TRUE
     }
     res
}

# __________________________________________________________ #
# For the locomotion_vs_stationary classification, this      #
# function identifies a PA (task) belongs to which class.    #
#                                                            #
# Locomotion PAs: Leisure Walk, Rapid Walk, Walking at       #
#                 RPE 1, Walking at RPE 5, Stair Ascent,     #
#                 Stair Descent.                             #
# Non-sedentary PAs: the rest.                               #
# ______________                                             #
# Matin Kheirkhahan (matinkheirkhahan@ufl.edu)               #
# __________________________________________________________ #
giveClassLabel_locomotion <- function(Task) {
     res <- FALSE
     if(Task %in% c("LEISURE WALK", "RAPID WALK", "WALKING AT RPE 1", "WALKING AT RPE 5", "STAIR ASCENT", "STAIR DESCENT")) {
          res <- TRUE
     }
     res
}
