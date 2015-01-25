Peer Assessment for course project in Getting and Cleaning Data on Coursera
=================================================================
Dataset
----------------------------
This is a README file which explains the modifications  to the 
[UCI HAR Human Activity Recognition using smartphones Dataset]
(http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) 
needed to complete the Coursera project for the Getting and 
Cleaning Data class. 

Included are two documents: 
-  run_analysis.R   - commented R code that performs the analysis described here
-  codebook.md   - provides translation between the feature names used by 
the original researchers and the cleaned data set
-  tidy dataset


Details about the original dataset
----------------------------------
The original dataset had 561 features. 30 subjects collected raw data in 6 different
activities, such as walking or laying. 

The raw measurements were obtained from the two sensors in 
the smartphone: an accelerometer and a gyroscope, each having X, Y and Z coordinates.
These are time seriers, meaning a collection of measurements of the same variable over time. 
From these 6 time series, many other features were computed:

*  magnitudes of vectors
*  separation of acceleration into body acceleration and gravity acceleration
*  derivative (called Jerk) of linear acceleration and angular momentum 
*  Fast Fourier Transforms of these to get signals in the frequency domain
*  13 different statistics functions, such as mean, standard deviation, skewness and others
*  angles between some other vectors


Order of steps performed for this project
--------------------------------------
Note to the reviewer: The steps suggested in the project were performed out of order. 
All "bind" operations were performed *before* merging with subject/activity, because
merge reorders rows. 

1.  *All data were read in* with the function read.table with sep="". This separator 
ignores whitespace. The 561-feature vector X_train is stored in a fixed-width format, 
which caused problems at the beginning. 

2.  *(Step 2 preparation) Columns of the original dataset, whose name contains "mean" or "std",
were identified with grepl*. This produced 46
columns with "mean" and 33 with "std". I included 13 columns matching meanFreq as those
required by this project. There are 13 more columns containing "Mean", but they appeared 
in the angle, and not a mean calculation, so I did not include them in our features. So, 
these represent 79 columns in the tidy dataset. 

3.  *(Step 4 preparation) Feature names were cleaned up*. The names in feature.txt contained characters
such as "(" and "-" which are not part of valid identifiers in R (alphanumeric, dot and underscore). 
This was because original researchers appended the name of the function applied to the data, 
and that name contained the parentheses of the function. 
gsub() was used throughout on 561 original feature names to: 
-  drop the parenthesis
-  replace "-" with a dot (to retain readability)
-  replace abbreviations such as Acc, Gyro, with Acceleration and Gyroscope
-  replace beginning t with "time" and beginning f with "frequency", 
-  replace X,Y,Z with more readable Xcoordinate, Ycoordinate, Zcoordinate,
-  replace Mag with Magnitude, and meanFreq with meanFrequency, 
-  replace mean with Mean and std with StandardDeviation for readability and consistency with CamelBack
-  fix a typo in the feature names i.e. replaced "BodyBody" with "Body"

Then, I output the dataframe of old and new feature names, which will become the codebook. 

4.  *(Step 1) Load and rbind() test and train subsets* of the X dataframe (561 features), y vector
(activity label) and subject vector. 

5.  *Actually perform Step 4 (clean feature names)* by assigning colnames to X (561-feature dataframe)

6.  *Actually perform Step 2* by selecting the columns of interest (79 mean and std columns)

7.  *(Step 3)* Replace the numeric activity label with a descriptive label (using dplyr merge)
 
8.  *(Step 5) Add subject and activity label columns* (using dplyr mutate) with appropriate labels.
Then group by activity (6 activities) and subject (30 subjects) and use summarise_each command 
to obtain the mean of every column by group.

Final Result
-------------------------------------------
tidy_dataset.txt has 180 (6 activities x 30 subjects) rows in 81 columns (46 mean columns, 33 std columns, 
activity label column, subject column). 
In addition, the units are changed: 
-  activity label is descriptive, not numeric  
-  for mean and std columns, all measurements for that column is averaged over time (keeping activity and 
subject constant) as compared with that column of the original data set.    
