Getting and Cleaning Data Course Assignment
---------------------------------------------------------------

##Goal

Companies like *FitBit, Nike,* and *Jawbone Up* are racing to develop the most advanced algorithms to attract new users. The data linked are collected from the accelerometers from the Samsung Galaxy S smartphone. 

A full description is available at the site where the data was obtained:  

<http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>

The data is available at:

<https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>

The aim of the project is to clean and extract usable data from the above zip file. R script called run_analysis.R that does the following:
- Merges the training and the test sets to create one data set.
- Extracts only the measurements on the mean and standard deviation for each measurement. 
- Uses descriptive activity names to name the activities in the data set
- Appropriately labels the data set with descriptive variable names. 
- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

In this repository, you find:

- *run_analysis.R* : the R-code run on the data set

- *Tidy.txt* : the clean data extracted from the original data using *run_analysis.R*

- *CodeBook.md* : the CodeBook reference to the variables in *Tidy.txt*

- *README.md* : the analysis of the code in *run_analysis.R*

- *analysis.html* : the html version of *README.md*

## Getting Started

###Basic Assumption
The R code in *run_analysis.R* proceeds under the assumption that the zip file available at <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip> is downloaded and extracted in the R Home Directory.

###Libraries Used

The libraries used are `data.table` and `dplyr`. `data.table` is preferable as it is more efficient in handling large data as tables. `dplyr` is used to aggregate variables to create the tidy data.

```
library(data.table)
library(dplyr)
```

###Read Supporting Files (Data)

The supporting files are the name of the features and the name of the activities. They are loaded into variables `featureNames` and `activityLabels`.
```
featureNames <- read.table("UCI HAR Dataset/features.txt")
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)
```
##Format training and test data

Both training and test data are divided into subject, activity and features. They are stored at three different files. 

###Read training data
```
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
activityTrain <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
featuresTrain <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)
```

###Read test data
```
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
activityTest <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
featuresTest <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)
```


##Step 1 - Merging the training and the test sets to create one single data set
We will merge the data in training and test data sets using row binding. The results are stored in `subject`, `activity` and `features`.
```
subject <- rbind(subjectTrain, subjectTest)
activity <- rbind(activityTrain, activityTest)
features <- rbind(featuresTrain, featuresTest)
```
###Naming the columns
The columns in the features data set can be named using names from `featureNames`. Other two columns we added "manually"

```
colnames(features) <- t(featureNames[2])
colnames(activity) <- "Activity"
colnames(subject) <- "Subject"
```

###Merging the all data
The data in `features`,`activity` and `subject` are merged and the complete data is now stored in `completeData`.

```
completeData <- cbind(features,activity,subject)
```

##Step 2 - Picking the measurements on the mean and standard deviation for each measurement

Extracting the columns that have mean or standard on it.
```
columnsWithMeanSTD <- grep(".*Mean.*|.*Std.*", names(completeData), ignore.case=TRUE)
```
Add `activity` and `subject` columns to the list 
```
requiredColumns <- c(columnsWithMeanSTD, 562, 563)
```
Creating `extractedData` with the selected columns. 
```
extractedData <- completeData[,requiredColumns]
```
##Step 3 - Uses descriptive activity names to name the activities in the data set
Changing `Activity` field to character type so we can add names.
```
extractedData$Activity <- as.character(extractedData$Activity)
for (i in 1:6){
extractedData$Activity[extractedData$Activity == i] <- as.character(activityLabels[i,2])
}
```
Converting `Activity` to factor type.
```{r}
extractedData$Activity <- as.factor(extractedData$Activity)
```
##Step 4 - Changing names to something more meaningful for better understanding
Reading the `extractedData`, the following acronyms could be be replaced:

- `Acc` can be replaced with Accelerometer

- `Gyro` can be replaced with Gyroscope

- `BodyBody` can be replaced with Body

- `Mag` can be replaced with Magnitude

- Character `f` can be replaced with Frequency

- Character `t` can be replaced with Time

```
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
```

##Step 5 - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

First need to convert `Subject` to a factor variable type. 
```
extractedData$Subject <- as.factor(extractedData$Subject)
extractedData <- data.table(extractedData)
```
tidyData will have average for each activity and subject.

```
tidyData <- aggregate(. ~Subject + Activity, extractedData, mean)
```
Order data inside tidyData
```
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]
```
Write to Tidy.txt file
```
write.table(tidyData, file = "Tidy.txt", row.names = FALSE)
```