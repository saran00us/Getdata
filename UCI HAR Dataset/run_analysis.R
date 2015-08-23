##Download the raw datafiles 

if(!file.exists("./week3")){dir.create("./week3")}
fileUrl <- “https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./week3/Dataset.zip",method="curl")
unzip(zipfile="./week3/Dataset.zip")

##read the files in the folder
file<-list.files("./week3/UCI HAR Dataset",recursive=TRUE)
X_test <- read.table("./week3/UCI HAR Dataset/test/X_test.txt",header=FALSE)
X_train <- read.table("./week3/UCI HAR Dataset/train/X_train.txt",header=FALSE)
y_test  <- read.table("./week3/UCI HAR Dataset/test/Y_test.txt",header=FALSE)
y_train <- read.table("./week3/UCI HAR Dataset/train/Y_train.txt",header=FALSE)
subject_test <- read.table("./week3/UCI HAR Dataset/test/subject_test.txt",header = FALSE)
subject_train <- read.table("./week3/UCI HAR Dataset/train/subject_train.txt",header = FALSE)

## Load reshape2 libraries 
library(reshape2)


# add column name for subject files
names(subject_train) <- "subjectID"
names(subject_test) <- "subjectID"

# add column names
featureNames <- read.table("./week3/UCI HAR Datasetfeatures.txt")
names(X_train) <- featureNames$V2
names(X_test) <- featureNames$V2
names(y_train) <- "activity"
names(y_test) <- "activity"

## combine files 
train <- cbind(subject_train, y_train, X_train)
test <- cbind(subject_test, y_test, X_test)
combined <- rbind(train, test)

# grab columns containing  "mean()" or "std()"
meanstdcols <- grepl("mean\\(\\)", names(combined)) |
grepl("std\\(\\)", names(combined))

meanstdcols[1:2] <- TRUE


combined <- combined[, meanstdcols]


## assign descriptive names to the dataframe


combined$activity <- factor(combined$activity, labels=c("Walking",
"Walking Upstairs", "Walking Downstairs", "Sitting", "Standing", "Laying"))


# create tidy data set
melted <- melt(combined, id=c("subjectID","activity"))
tidy <- dcast(melted, subjectID+activity ~ variable, mean)
names(tidy) <- gsub("^t", "time", names(tidy))
names(tidy)<-gsub("^f", "frequency", names(tidy))
names(tidy)<-gsub("Acc", "Accelerometer", names(tidy))
names(tidy)<-gsub("Gyro", "Gyroscope", names(tidy))
names(tidy)<-gsub("Mag", "Magnitude", names(tidy))
names(tidy)<-gsub("BodyBody", "Body", names(tidy))
library(plyr);
tidy2<-aggregate(. ~subjectID + activity, tidy, mean)
tidy2<-tidy2[order(tidy2$subjectID,tidy2$activity),]
# write the tidy data set to a file
write.table(tidy2,file = "tidydata.txt",row.name=FALSE)

