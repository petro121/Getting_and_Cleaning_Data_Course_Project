#Unzip the archive into the folder with this script
setwd("./UCI HAR Dataset")

# Firstly we will load the needed libraries (Please install them manually before
#running this script)
# Library for cleaning data
library(dplyr)
# Library for working with datatables, like dataframes, but better
library(data.table)


# 1. Merge the training and the test sets to create one data set

# We read the files into datatables
subjectTrain = read.table('./train/subject_train.txt',header=FALSE)
xTrain = read.table('./train/x_train.txt',header=FALSE)
yTrain = read.table('./train/y_train.txt',header=FALSE)
subjectTest = read.table('./test/subject_test.txt',header=FALSE)
xTest = read.table('./test/x_test.txt',header=FALSE)
yTest = read.table('./test/y_test.txt',header=FALSE)

#Now we merge the train and test data
xDataSet <- rbind(xTrain, xTest)
yDataSet <- rbind(yTrain, yTest)
subjectDataSet <- rbind(subjectTrain, subjectTest)


# 2. Extract only the measurements on the mean 
#and standard deviation for each measurement

# From xDataSet we extract only the columns, numbers of which correspond to
#numbers in "features.txt" next to features with "-mean()" or "-std()". Then 
#we name the columns of xDataSet appropriately
xDataSet_mean_std <- xDataSet[, grep("-(mean|std)\\(\\)", read.table("features.txt")[, 2])]
names(xDataSet_mean_std) <- read.table("features.txt")[grep("-(mean|std)\\(\\)", read.table("features.txt")[, 2]), 2]


# 3. Use descriptive activity names to name the activities in the data set

yDataSet[, 1] <- read.table("activity_labels.txt")[yDataSet[, 1], 2]
names(yDataSet) <- "Activity"


# 4. Appropriately label the data set with descriptive activity names

# As for subjectDataSet, we just rename its column
names(subjectDataSet) <- "Subject"

# Organizing and combining all data sets into single one.
singleDataSet <- cbind(xDataSet_mean_std, yDataSet, subjectDataSet)

# Defining descriptive names for all variables.
names(singleDataSet) <- make.names(names(singleDataSet))
names(singleDataSet) <- gsub('Acc',"Acceleration",names(singleDataSet))
names(singleDataSet) <- gsub('GyroJerk',"AngularAcceleration",names(singleDataSet))
names(singleDataSet) <- gsub('Gyro',"AngularSpeed",names(singleDataSet))
names(singleDataSet) <- gsub('Mag',"Magnitude",names(singleDataSet))
names(singleDataSet) <- gsub('^t',"TimeDomain.",names(singleDataSet))
names(singleDataSet) <- gsub('^f',"FrequencyDomain.",names(singleDataSet))
names(singleDataSet) <- gsub('\\.mean',".Mean",names(singleDataSet))
names(singleDataSet) <- gsub('\\.std',".StandardDeviation",names(singleDataSet))
names(singleDataSet) <- gsub('Freq\\.',"Frequency.",names(singleDataSet))
names(singleDataSet) <- gsub('Freq$',"Frequency",names(singleDataSet))


# 5. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject

Data2<-aggregate(. ~Subject + Activity, singleDataSet, mean)
Data2<-Data2[order(Data2$Subject,Data2$Activity),]

#The final result is stored in tidydata.txt
write.table(Data2, file = "tidydata.txt",row.name=FALSE)