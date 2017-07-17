# Private file to clean Energy Expenditure (MET) data file
cosmed.raw <- read.csv(file.choose())
cosmed.df <- cosmed.raw[, c(1, 16, 87, 89)] # PID, Activity, MET, Intensity
rm(cosmed.raw)

levels(as.factor(cosmed.df$activity))
cosmed.df$Task <- toupper(cosmed.df$activity)
cosmed.df$Task[cosmed.df$activity == "computer_work"] <- "COMPUTER WORK"
cosmed.df$Task[cosmed.df$activity == "heavy_lifting"] <- "HEAVY LIFTING"
cosmed.df$Task[cosmed.df$activity == "laundry_washing"] <- "LAUNDRY WASHING"
cosmed.df$Task[cosmed.df$activity == "leisure_walk"] <- "LEISURE WALK"
cosmed.df$Task[cosmed.df$activity == "light_gardening"] <- "LIGHT GARDENING"
cosmed.df$Task[cosmed.df$activity == "light_home_maintance"] <- "LIGHT HOME MAINTENANCE"
cosmed.df$Task[cosmed.df$activity == "personal_care"] <- "PERSONAL CARE"
cosmed.df$Task[cosmed.df$activity == "prepare_serve_meal"] <- "PREPARE SERVE MEAL"
cosmed.df$Task[cosmed.df$activity == "rapid_walk"] <- "RAPID WALK"
cosmed.df$Task[cosmed.df$activity == "replacing_bed_sheets"] <- "REPLACING SHEETS ON A BED"
cosmed.df$Task[cosmed.df$activity == "stair_ascent"] <- "STAIR ASCENT"
cosmed.df$Task[cosmed.df$activity == "stair_descent"] <- "STAIR DESCENT"
cosmed.df$Task[cosmed.df$activity == "standing_still"] <- "STANDING STILL"
cosmed.df$Task[cosmed.df$activity == "straightening_up_dusting"] <- "STRAIGHTENING UP DUSTING"
cosmed.df$Task[cosmed.df$activity == "strength_chest"] <- "STRENGTH EXERCISE CHEST PRESS"
cosmed.df$Task[cosmed.df$activity == "strength_legcurl"] <- "STRENGTH EXERCISE LEG CURL"
cosmed.df$Task[cosmed.df$activity == "strength_legext"] <- "STRENGTH EXERCISE LEG EXTENSION"
cosmed.df$Task[cosmed.df$activity == "stretching_yoga"] <- "STRETCHING YOGA"
cosmed.df$Task[cosmed.df$activity == "trash_removal"] <- "TRASH REMOVAL"
cosmed.df$Task[cosmed.df$activity == "tv_watching"] <- "TV WATCHING"
cosmed.df$Task[cosmed.df$activity == "unloading_storing_dishes"] <- "UNLOADING STORING DISHES"
cosmed.df$Task[cosmed.df$activity == "walk_rpe_1"] <- "WALKING AT RPE 1"
cosmed.df$Task[cosmed.df$activity == "walk_rpe_5"] <- "WALKING AT RPE 5"
cosmed.df$Task[cosmed.df$activity == "washing_dishes"] <- "WASHING DISHES"
cosmed.df$Task[cosmed.df$activity == "washing_windows"] <- "WASHING WINDOWS"
cosmed.df$Task[cosmed.df$activity == "yard_work"] <- "YARD WORK"
cosmed.df <- cosmed.df[, c(1, 5, 3, 4)]
colnames(cosmed.df) <- c("PID", "Task", "METs", "MET_Intensity")
saveRDS(cosmed.df, "~/Workspaces/R workspace/Comparative Activity Recognition/Utilities/MET_values.Rdata")
