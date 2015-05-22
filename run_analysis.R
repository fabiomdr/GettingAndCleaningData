## load libraries to handle the data
library(data.table)
library(dplyr)

## Assuming the zipped file was downloaded, 
## unzipped and stored at working directory
## Files to be read are features.txt and activity_labels.txt
featureNames <- read.table("UCI HAR Dataset/features.txt")
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)

## Reading the files containing the subject, activity and features
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
activityTrain <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
featuresTrain <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)

## Reading the test data for the subject, activity and feature
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
activityTest <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
featuresTest <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)

## Merging the data of training and test sets into one data set
subject <- rbind(subjectTrain, subjectTest)
activity <- rbind(activityTrain, activityTest)
features <- rbind(featuresTrain, featuresTest)

## Put names in the columns
colnames(features) <- t(featureNames[2])
colnames(activity) <- "Activity"
colnames(subject) <- "Subject"

## Merging the all data into completeData
completeData <- cbind(features,activity,subject)

## Extracting the columns that have mean or standard on it
columnsWithMeanSTD <- grep(".*Mean.*|.*Std.*", names(completeData), ignore.case=TRUE)

## Adding activity and subject columns to the list
requiredColumns <- c(columnsWithMeanSTD, 562, 563)

## Creating extractedData with the selected columns
extractedData <- completeData[,requiredColumns]

## change activity field to character type so we can add names
extractedData$Activity <- as.character(extractedData$Activity)
for (i in 1:6){
        extractedData$Activity[extractedData$Activity == i] <- as.character(activityLabels[i,2])
}

## converting to factor
extractedData$Activity <- as.factor(extractedData$Activity)

## Changing names to something more meaningful for better understanding
names(extractedData)<-gsub("Acc", "Accelerometer", names(extractedData))
names(extractedData)<-gsub("Gyro", "Gyroscope", names(extractedData))
names(extractedData)<-gsub("BodyBody", "Body", names(extractedData))
names(extractedData)<-gsub("Mag", "Magnitude", names(extractedData))
names(extractedData)<-gsub("^t", "Time", names(extractedData))
names(extractedData)<-gsub("^f", "Frequency", names(extractedData))
names(extractedData)<-gsub("tBody", "TimeBody", names(extractedData))
names(extractedData)<-gsub("-mean()", "Mean", names(extractedData), ignore.case = TRUE)
names(extractedData)<-gsub("-std()", "STD", names(extractedData), ignore.case = TRUE)
names(extractedData)<-gsub("-freq()", "Frequency", names(extractedData), ignore.case = TRUE)
names(extractedData)<-gsub("angle", "Angle", names(extractedData))
names(extractedData)<-gsub("gravity", "Gravity", names(extractedData))

## Let's create the second data set of Tidy data

## converting extractedData to factor type
extractedData$Subject <- as.factor(extractedData$Subject)
extractedData <- data.table(extractedData)

## tidyData will have average for each activity and subject
tidyData <- aggregate(. ~Subject + Activity, extractedData, mean)

## Order data inside tidyData
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]

## Write to Tidy.txt file
write.table(tidyData, file = "Tidy.txt", row.names = FALSE)
