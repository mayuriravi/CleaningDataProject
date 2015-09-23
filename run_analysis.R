##set the path to the Test, Train, and Main file locations
#pathTest <- "...\\UCI HAR Dataset\\test\\"
#pathTrain <- "...\\UCI HAR Dataset\\train\\"
#pathMain <- "...\\UCI HAR Dataset\\"

pathTest <- paste0(getwd(),"/test/")
pathTrain <- paste0(getwd(),"/train/")
pathMain <- getwd()

## install package deplyr
install.packages("dplyr")
##include deplyr package
library("dplyr")
## assign various file names to variables
filevar1 <- "X_test.txt"
filevar2 <- "X_train.txt"
filevar3 <- "activity_labels.txt"
filevar4 <- "subject_test.txt"
filevar5 <- "y_test.txt"
filevar6 <- "subject_train.txt"
filevar7 <- "y_train.txt"
headfile <- "features.txt"

## read the test X file 
dataxtest <- read.table(paste(pathTest, filevar1, sep=""))
## read the test y file
dataytest <- read.table(paste(pathTest, filevar5, sep=""))
## read the test subject file
datatestsubject <- read.table(paste(pathTest, filevar4, sep=""))

# change column name of datatestsubject
colnames(datatestsubject) <- c("Subject")

#read the header file
head1 <- read.csv(paste(pathMain, headfile, sep=""), header=FALSE, sep=" ")

#cleanup header data * remove () & blank spces, replace ',' with '-'
head1$V2 <- gsub("\\(\\)","", head1$V2)
head1$V2 <- gsub("\\(", "-", head1$V2)
head1$V2 <- gsub("\\)", "", head1$V2)
head1$V2 <- gsub("\\,", "-", head1$V2)

##Set the column name to header data of dataxtest
colnames(dataxtest)<- head1$V2

# read the train X file
dataxtrain <- read.table(paste(pathTrain, filevar2, sep=""))
# read the train y file
dataytrain <- read.table(paste(pathTrain, filevar7, sep=""))
## read the train subject file
datatrainsubject <- read.table(paste(pathTrain, filevar6, sep=""))


# change column name of datatrainsubject
colnames(datatrainsubject) <- c("Subject")

##Set the column name to header data of dataxtest
colnames(dataxtrain)<- head1$V2

#read the activity labels file
actlbls <- read.csv(paste(pathMain, filevar3, sep=""), header=FALSE, sep=" ")

# find activity lable for each y training set
ytrainacts <- merge(dataytrain, actlbls, by.x="V1", by.y="V1")

#change the column names of the merged ytrainacts data 
colnames(ytrainacts) <- c("testlblValue", "ActivityName")

##combine training x and y datasets
combinedxytrain <- cbind(dataxtrain, ytrainacts, make.column.names = FALSE)

##combine training xy dataset with Subject data
combinedxytrain <- cbind(combinedxytrain, datatrainsubject, make.column.names = FALSE)

# find activity lable for each y test set
ytestacts <- merge(dataytest, actlbls, by.x="V1", by.y="V1")

#change the column names of the merged ytrainacts data 
colnames(ytestacts) <- c("testlblValue", "ActivityName")


##combine test x and y data sets
combinedxytest <- cbind.data.frame(dataxtest, ytestacts, make.column.names = FALSE)

##combine test x,y and Subject data sets
combinedxytest <- cbind.data.frame(combinedxytest, datatestsubject, make.column.names = FALSE)


##combine final test and train data sets with only the needed columns mean, std, and activityName
combinedData <- rbind.data.frame(combinedxytest[,grep("mean|std|ActivityName|Subject", names(combinedxytest))], 
                combinedxytrain[,grep("mean|std|ActivityName|Subject", names(combinedxytrain))], make.row.names = FALSE)

## convert Subject to a factor to support grouping
combinedData$Subject <- as.factor(combinedData$Subject)

## create the summary data file
finalTidyDat <- group_by(combinedData[order(combinedData$Subject, combinedData$ActivityName),], Subject, ActivityName) %>% summarise_each(c("mean"))

##write the output to the text file

write.table(finalTidyDat, file="finalTidyData.txt", row.names=FALSE)
