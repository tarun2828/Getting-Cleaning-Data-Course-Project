library(dplyr)

# create a directory to place the file if one doesn't exist
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

#unzip the downloaded file

unzip(zipfile="./data/Dataset.zip",exdir="./data")
path <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)

## read the activity files
activityTest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
activityTrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)
# read the subject data
subjectTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
subjectTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)

## read the features details
featuresTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
featuresTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

# Concatenate the tables
subjectData <- rbind(subjectTrain, subjectTest)
activityData<- rbind(activityTrain, activityTest)
featuresData<- rbind(featuresTrain, featuresTest)

# set variable names
names(subjectData)<-c("subject")
names(activityData)<- c("activity")
featuresNames <- read.table(file.path(path, "features.txt"),head=FALSE)
names(featuresData)<- featuresNames$V2

# merge the columns
mergeData <- cbind(subjectData, activityData)
finalData <- cbind(featuresData, mergeData)

# get the mean and the standard deviation
subFeaturesNames<-featuresNames$V2[grep("mean\\(\\)|std\\(\\)", featuresNames$V2)]

# subset of data by feature name
selectNames<-c(as.character(subFeaturesNames), "subject", "activity" )
finalData<-subset(finalData,select=selectNames)

# read the descriptive actiivty names from the text file
activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)

names(finalData)<-gsub("^t", "time", names(finalData))
names(finalData)<-gsub("^f", "frequency", names(finalData))
names(finalData)<-gsub("Acc", "Accelerometer", names(finalData))
names(finalData)<-gsub("Gyro", "Gyroscope", names(finalData))
names(finalData)<-gsub("Mag", "Magnitude", names(finalData))
names(finalData)<-gsub("BodyBody", "Body", names(finalData))

# create the tidy data set

tidyData<-aggregate(. ~subject + activity, finalData, mean)
tidyData<-tidyData[order(tidyData$subject,tidyData$activity),]
write.table(tidyData, file = "tidydata.txt",row.name=FALSE)