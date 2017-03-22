#read the features
features<-read.table("features.txt", col.names=c("feature_pos","feature_name"))
#read the activities
activities<-read.table("activity_labels.txt", col.names=c("activity_label","activity_name"))
#read the test set, assign to the variables the names of the features 
test<-read.table("X_test.txt", col.names=features$feature_name)
#read the activities related to the test set
test_labels<-read.table("y_test.txt", col.names="activity")
#read the subjects related to the test set
test_subject<-read.table("subject_test.txt", col.names="subject")
#combine test, test_labels and test_subject in one data set
test<-cbind(test, test_labels, test_subject)
#read the train set, assign to the variables the names of the features 
train<-read.table("X_train.txt", col.names=features$feature_name)
#read the activities related to the train set
train_labels<-read.table("y_train.txt", col.names="activity")
#read the subjects related to the train set
train_subject<-read.table("subject_train.txt", col.names="subject")
#combine train, train_labels and train_subject in one data set
train<-cbind(train, train_labels, train_subject)
#merge the train and test data sets
data<-rbind(test, train)
library(dplyr)
#choose the feature related to a mean or a standard deviation
features<-filter(features, grepl("mean\\(|std", feature_name))
#select the columns in data related to a mean or a standard deviation
data2<-select(data, features$feature_pos)
#combine the variables related to a mean or a standard deviation with activity label and subject
data<-cbind(activity=data$activity, subject=data$subject, data2)
#replace the label for the activity with the related descriptive name
for (i in 1:dim(activities)[1]) {
    data$activity<-sub(activities$activity_label[i], activities$activity_name[i], data$activity)
}
#group the data by activity and subject
grouped<-group_by(data, activity, subject)
#create a new data set with the mean related to each group of every other non grouped variable
new_data<-summarise_each(grouped, "mean")
#create new names for the new data set
new_names<-paste("MEAN", features$feature_name, sep="_")
#assigning these names to the variables in new_data
names(new_data)<-c("activity", "subject", new_names)
#write the data
write.table(new_data, "tidy_data.txt", row.names=FALSE)