library(dplyr)

# Load the Human Activity Recognition Using Smartphones Data Set to your local
# directory

if(!file.exists("./course_project")) {dir.create("./course_project")}
fileUrl <-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
download.file(fileUrl, destfile = "/course_project/Dataset.zip", method="curl")
unzip("Dataset.zip")
list.files("UCI HAR Dataset")

# load the files with variables names and activity lables to 
# to the R environment 
setwd("/course_project/UCI HAR Dataset")

list.files()

features<- as.character(read.table("features.txt", sep=" ", 
                       header=FALSE)[,2])

activity_labels<- read.table("activity_labels.txt",
                                    sep=" ", header=FALSE,
                                    col.names = c("activity","labels"))

# Read the files in the Test or Train files 

setwd("/course_project/UCI HAR Dataset/test")

x_test<- tbl_df(read.table("X_test.txt", sep="", header=FALSE))

y_test<- tbl_df(read.table("y_test.txt", sep="", header=FALSE,
                           col.names = ("activity")))

subject_test<- tbl_df(read.table("subject_test.txt", sep="", header=FALSE,
                                 col.names = ("subject"))) 

# Bind the columns of the x_test, y_test and subject_test data frames. Remove 
# the files after binding.
xy_test<- tbl_df(cbind(subject_test, y_test, x_test))
rm(y_test,subject_test,x_test)

# Repeat the same process for the Train files.

setwd("/UCI HAR Dataset/train")

x_train<- tbl_df(read.table("X_train.txt", sep="", header=FALSE))

y_train<- tbl_df(read.table("y_train.txt", sep="", header=FALSE,
                            col.names = ("activity")))

subject_train<- tbl_df(read.table("subject_train.txt", sep="", header=FALSE,
                                  col.names = ("subject"))) 

xy_train<- tbl_df(cbind(subject_train, y_train, x_train))
rm(y_train,subject_train,x_train)

## Bind the two data frames 
datacomplete<- bind_rows(xy_train, xy_test, .id= "dataset")

# Merge the activity names with the datacomplete datra frame.
datacomplete<- merge(activity_labels, datacomplete)
rm(xy_train, xy_test,activity_labels)

# Name the rest of the variables with the features values.
colnames(datacomplete)[5:565] <- features

# Store the positions of the columns that have ethier mean or std.
MeanAndStd<- grep("labels|subject|[Mm]ean|[Ss]td",
                  colnames(datacomplete))

## Make the variables names legible.

colnames(datacomplete)<- tolower(colnames(datacomplete))
colnames(datacomplete)<- gsub("-","",colnames(datacomplete)) 
colnames(datacomplete)<- gsub("()","",colnames(datacomplete), fixed=TRUE)
colnames(datacomplete)<- gsub("^[f]","frecuency",colnames(datacomplete))
colnames(datacomplete)<- gsub("[Aa]cc?","acceleration",colnames(datacomplete)) 
colnames(datacomplete)<- gsub("^[t]","time",colnames(datacomplete))
colnames(datacomplete)<- gsub("[Cc]oeff","coefficient",colnames(datacomplete))
colnames(datacomplete)<- gsub("std","standardeviation",colnames(datacomplete))
colnames(datacomplete)<- gsub("x$","xaxis",colnames(datacomplete))
colnames(datacomplete)<- gsub("y$","yaxis",colnames(datacomplete))
colnames(datacomplete)<- gsub("z$","zaxis",colnames(datacomplete))
colnames(datacomplete)<- gsub("mad","medianabsolutedeviation", 
                              colnames(datacomplete))
colnames(datacomplete)<- gsub("sma","sinalmagnitudearea", 
                              colnames(datacomplete))
colnames(datacomplete)<- gsub("iqr","interquartilerange", 
                              colnames(datacomplete))
colnames(datacomplete)<- gsub("arCoeff","autorregresioncoefficients", 
                              colnames(datacomplete))

# Select the variables of datacomplete that are relevant
datacomplete<- datacomplete[c(MeanAndStd)]
colnames(datacomplete)[1:2]<- c("activity","subject")

# Create a tidy data frame grouping by subject and activity. Summarize each
# column showing the mean of each variable.
tidydata<- datacomplete %>% group_by(subject, activity) %>%
        summarize_each(funs(mean))
rm(datacomplete,features, MeanAndStd,fileUrl)

# Write a table

write.table(tidydata, "tidydata.txt",row.name=FALSE)



