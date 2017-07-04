UnigramFeatures.df <- readRDS(file="C:/Users/shikh/Documents/University of Florida/Activity Recognition/Datasets/Raw Data/Training_Set/nGram_Files/UnigramFeatures.Rdata")
BigramFeatures.df <- readRDS(file="C:/Users/shikh/Documents/University of Florida/Activity Recognition/Datasets/Raw Data/Training_Set/nGram_Files/BigramFeatures.Rdata")

# dataPoints<-UnigramFeatures.df[UnigramFeatures.df$PID=="ADAD151" & (UnigramFeatures.df$Task=="TV WATCHING" | 
#                                 UnigramFeatures.df$Task=="LEISURE WALK" | 
#                                 UnigramFeatures.df$Task=="DIGGING"),]

# dataPoints<-UnigramFeatures.df[UnigramFeatures.df$PID=="ADAD151",]

dataPoints<-UnigramFeatures.df[UnigramFeatures.df$Task=="TV WATCHING" | 
                                UnigramFeatures.df$Task=="LEISURE WALK" | 
                                UnigramFeatures.df$Task=="DIGGING",]

attach(dataPoints)
library(ggplot2)
library(gridExtra)

plot1<-ggplot(dataPoints, aes(x = Task, y = B0)) + geom_bar(aes(fill = Task),stat = 'identity', position = "dodge") + ggtitle("B0") + theme(axis.title.x=element_blank(),axis.title.y=element_blank(),legend.position="none")
plot2<-ggplot(dataPoints, aes(x = Task, y = B1)) + geom_bar(aes(fill = Task),stat = 'identity', position = "dodge") + ggtitle("B1") + theme(axis.title.x=element_blank(),axis.title.y=element_blank(),legend.position="none")
plot3<-ggplot(dataPoints, aes(x = Task, y = B2)) + geom_bar(aes(fill = Task),stat = 'identity', position = "dodge") + ggtitle("B2") + theme(axis.title.x=element_blank(),axis.title.y=element_blank(),legend.position="none")
plot4<-ggplot(dataPoints, aes(x = Task, y = B3)) + geom_bar(aes(fill = Task),stat = 'identity', position = "dodge") + ggtitle("B3") + theme(axis.title.x=element_blank(),axis.title.y=element_blank(),legend.position="none")
plot5<-ggplot(dataPoints, aes(x = Task, y = B4)) + geom_bar(aes(fill = Task),stat = 'identity', position = "dodge") + ggtitle("B4") + theme(axis.title.x=element_blank(),axis.title.y=element_blank(),legend.position="none")
plot6<-ggplot(dataPoints, aes(x = Task, y = B5)) + geom_bar(aes(fill = Task),stat = 'identity', position = "dodge") + ggtitle("B5") + theme(axis.title.x=element_blank(),axis.title.y=element_blank(),legend.position="none")
plot7<-ggplot(dataPoints, aes(x = Task, y = B6)) + geom_bar(aes(fill = Task),stat = 'identity', position = "dodge") + ggtitle("B6") + theme(axis.title.x=element_blank(),axis.title.y=element_blank(),legend.position="none")
plot8<-ggplot(dataPoints, aes(x = Task, y = B7)) + geom_bar(aes(fill = Task),stat = 'identity', position = "dodge") + ggtitle("B7") + theme(axis.title.x=element_blank(),axis.title.y=element_blank(),legend.position="none")
plot9<-ggplot(dataPoints, aes(x = Task, y = B8)) + geom_bar(aes(fill = Task),stat = 'identity', position = "dodge") + ggtitle("B8") + theme(axis.title.x=element_blank(),axis.title.y=element_blank(),legend.position="none")
plot10<-ggplot(dataPoints, aes(x = Task, y = B9)) + geom_bar(aes(fill = Task),stat = 'identity', position = "dodge") + ggtitle("B9") + theme(axis.title.x=element_blank(),axis.title.y=element_blank())

grid.arrange(plot1,plot2,plot3,plot4,plot5,plot6,plot7,plot8,plot9,plot10,nrow=4,ncol=3)
