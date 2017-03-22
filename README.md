---
title: "README.md"
author: "Francesca Tantardini"
date: "22 marzo 2017"
output: html_document
---


#The script run_analysis.R

The script **run_analysis.R** creates a tidy dataset from the data available at <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>  in the way described below.

##Reading the data
First, the script reads the file **features.txt** and names its colums "feature_pos" and "feature_name"
```{r}
features<-read.table("features.txt", col.names=c("feature_pos","feature_name"))
```
The first column contains in fact the number ("position") related to the feature in the second column.
As second step it reads the activities from the file **activity_labels.txt**, so that we have a link between activity label and activity name. 
```{r}
activities<-read.table("activity_labels.txt", col.names=c("activity_label","activity_name"))
```
It reads the test set from the file **X_test.txt** assigns to the variables the names of the features, so that we have already descriptive names. 
```{r}
test<-read.table("X_test.txt", col.names=features$feature_name)
```
It reads also the activities and the subjects related to the test set from the files **y_test.txt** and  **subject_test.txt** respectively and combines it with the **test** dataset in order to have a unique dataset.
```{r}
test_labels<-read.table("y_test.txt", col.names="activity")
test_subject<-read.table("subject_test.txt", col.names="subject")
test<-cbind(test, test_labels, test_subject)
```
The same procedure for the train set:
```{r}
train<-read.table("X_train.txt", col.names=features$feature_name)
train_labels<-read.table("y_train.txt", col.names="activity")
train_subject<-read.table("subject_train.txt", col.names="subject")
train<-cbind(train, train_labels, train_subject)
```
The **train** and **test** data sets are then merged in one data set
```{r}
data<-rbind(test, train)
```
##Filtering the data
The library **dplyr** is loaded to use the function **filter** to choose the feature related to a mean or a standard deviation, that is, those features in whose name appear the strings "mean(" (the open parenthesis helps to avoid meanFreq) or "std"
```{r}
library(dplyr)
features<-filter(features, grepl("mean\\(|std", feature_name))
```
We select the columns of data related to the remained features, and combine the activity and subject
```{r}
data2<-select(data, features$feature_pos)
data<-cbind(activity=data$activity, subject=data$subject, data2)
```
##Renaming
The columns have already decriptive names, as we used read.table with an appropriate argument for col.names. The labels for the activity are now replaced by their descriptive name
```{r}
for (i in 1:dim(activities)[1]) {
    data$activity<-sub(activities$activity_label[i], activities$activity_name[i], data$activity)
}
```
##Taking the mean related to each activity and subject
We group the rows by activity and subject and create a new data set with the mean related to each group of every other non grouped variable
```{r}
grouped<-group_by(data, activity, subject)
new_data<-summarise_each(grouped, "mean")
```
We create new names for the new data set by appenading at the beginning if the feature_name the string "MEAN_"
```{r}
new_names<-paste("MEAN", features$feature_name, sep="_")
names(new_data)<-c("activity", "subject", new_names)
```

The **new_data** is  finally written to a file by means of the **write.table** command. Please use **read.table** with **header=TRUE** to read it. 
