participantData <- readRDS(file="C:/Users/shikh/Documents/University of Florida/Activity Recognition/Datasets/Raw Data/Training_Set/ALSH094_downsampled_Data.Rdata")
attach(participantData)

par(mfrow=c(1,3))
plot(VM[TaskLabel=="DIGGING"],ylim=c(min(VM),max(VM)),las=1,type="l",ylab="Vector Magnitude",xlab="",main="Participant ALSH094 - Digging",col=2,col.main=2,cex.main=1.5,cex.lab=1.5)
plot(VM[TaskLabel=="LEISURE WALK"],ylim=c(min(VM),max(VM)),las=1,type="l",ylab="Vector Magnitude",xlab="",main="Participant ALSH094 - Leisure Walk",col=3,col.main=3,cex.main=1.5,cex.lab=1.5)
plot(VM[TaskLabel=="TV WATCHING"],ylim=c(min(VM),max(VM)),las=1,type="l",ylab="Vector Magnitude",xlab="",main="Participant ALSH094 - TV Watching",col=4,col.main=4,cex.main=1.5,cex.lab=1.5)
