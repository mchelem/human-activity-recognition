#!/usr/bin/env Rscript

library(data.table)

read.activities <- function() {
	activities = read.table("UCI HAR Dataset/activity_labels.txt", colClasses=c("numeric", "character"))
	names(activities) <- c("id","activity")

	# Improve activities' name readability
	activities$activity <- tolower(activities$activity)
	activities$activity <- sub("_", " ", activities$activity)
	activities
}


read.features <- function() {	
	features <- read.table("UCI HAR Dataset/features.txt", colClasses=c("numeric", "character"))
	names(features) <- c("id", "name")

	# Select only features of interest (mean and standard deviation)
	features <- features[grepl("mean\\(|std\\(",features$name),]
	# Remove spare parenthesis
	features$name <- sub("()", "", features$name)
	features
}

read.subject <- function(type) {
	subject <- read.table(paste("UCI HAR Dataset/", type ,"/subject_", type, ".txt", sep=""))
	names(subject) <- c("subject")
	subject
}


read.y <- function(type) {
	y <- read.table(paste("UCI HAR Dataset/", type ,"/y_", type, ".txt", sep=""))
	activities <- read.activities()
	names(y) <- c("id")
	y <- merge(y, activities, by="id")
	y$id <- NULL
	y
}

read.X <- function(type) {
	X <- read.table(paste("UCI HAR Dataset/", type ,"/X_", type, ".txt", sep=""))
	features <- read.features()
	X <- X[, features$id]
	names(X) <- features$name
	X
}


message("Preparing data set. This may take a while...")
train.dataset <- cbind(read.subject("train"), read.y("train"), read.X("train"))
test.dataset <- cbind(read.subject("test"), read.y("test"), read.X("test"))
dataset <- rbind(train.dataset, test.dataset)
DT <- data.table(dataset)
dataset <- DT[,lapply(.SD,mean),by=c("subject,activity"]

output.file <- "subject-activity-means.txt"
write.table(dataset, output.file)
message(paste("Finished. Result saved to", output.file, "."))
