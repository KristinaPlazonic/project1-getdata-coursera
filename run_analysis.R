#### reading in the features positions and names
nm = read.table("features.txt", sep = "", stringsAsFactors = FALSE, 
                col.names = c("index", "old_feature"))

nm$feature = nm$old_feature ### adding another column where we clean up feature names

### computing subset of columns to extract from X_train and X_test (for step 2)
mean_index = grepl("mean", nm$feature, ignore.case = FALSE)
std_index = grepl("std", nm$feature, ignore.case = TRUE)
cols_to_extract = mean_index | std_index

### cleaning feature names  (for Step 4 of the assignment)
nm$feature = gsub("[\\(\\)]", "",nm$feature) #### remove "()" - not allowed in var name
nm$feature = gsub("-", ".", nm$feature)      #### replace "-" with "."
nm$feature = gsub("Acc", "Acceleration", nm$feature) #### replace name
nm$feature = gsub("Gyro", "Gyroscope", nm$feature) #### replace name
nm$feature = sub("^t", "time", nm$feature) #### replace t at the beginning with time
nm$feature = sub("^f", "frequency", nm$feature) #### replace f at the beginning with frequency
nm$feature = sub("X$", "Xcoordinate", nm$feature) #### replace X at the end with Xcoordinate
nm$feature = sub("Y$", "Ycoordinate", nm$feature) #### replace Y at the end with Ycoordinate
nm$feature = sub("Z$", "Zcoordinate", nm$feature) #### replace Z at the end with Zcoordinate
nm$feature = sub("Mag", "Magnitude", nm$feature) #### replace Mag with Magnitude
nm$feature = sub("meanFreq", "MeanFrequency", nm$feature) #### replace Freq with Frequency
nm$feature = sub("mean", "Mean", nm$feature) #### keep with CamelBack convention
nm$feature = sub("std", "StandardDeviation", nm$feature) #### keep with CamelBack convention
nm$feature = sub("BodyBody", "Body", nm$feature) #### fix the typo in feature names

write.table(nm[cols_to_extract,], file = "newfeatures.txt", row.names = FALSE, sep = ",")

### putting test and train sets together (step 1 of the assignment)
testx = read.table("test/X_test.txt", header = FALSE, 
                as.is = TRUE, sep = "")
testy = read.table("test/y_test.txt", header = FALSE)
testsubject = read.table("test/subject_test.txt", header = FALSE)


trainx = read.table("train/X_train.txt", header = FALSE, 
                 as.is = TRUE, sep = "")
trainy = read.table("train/y_train.txt", header = FALSE)
trainsubject = read.table("train/subject_train.txt", header = FALSE)


measurements = rbind(testx, trainx)
response = rbind(testy, trainy)
subjects = rbind(testsubject, trainsubject)


### Step 4 of the assignment - give descriptive names to variables
colnames(measurements) = nm$feature         ### giving dataframe good column names
#colnames(response) = c("activity.numeric")

#### Step 2 of the assignment - extracting only mean and std features
selected.measurements = measurements[,cols_to_extract]  ### extracting mean and std columns

#### Completing Step 1 of the assignemt - adding the activity numeric label and subject
selected.measurements = mutate(selected.measurements, 
                               activity.numeric = response$V1, 
                               subject = subjects$V1)

### activity levels - descriptive names (preparation for Step 3)
act.labels = read.table("activity_labels.txt", header = FALSE, 
                        stringsAsFactors = FALSE, sep = "",
                        col.names = c("ActivityLabel", "descriptiveActivity"))
act.labels$descriptiveActivity = sub("_", " ", act.labels$descriptiveActivity)

### step 3 of the assignment - replace numeric activity labels 1-6 with "WALKING" etc
result = merge(selected.measurements, act.labels, 
               by.x = "activity.numeric", by.y = "ActivityLabel")
result = select(result, -c(activity.numeric))  # removing the unnecessary column

### step 5 of the assignment - group by subject and activity 
by_subject_activity = group_by(result, subject, descriptiveActivity)
tidydf = summarise_each(by_subject_activity, funs(mean))  ### summarise_each works on each column

write.table(tidydf, "tidy_dataset.txt", sep=",", col.names = TRUE, row.names = FALSE)
