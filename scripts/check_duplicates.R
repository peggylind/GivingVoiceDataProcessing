# Duplicate checking in documents by reading in files from a given folder and filter out duplicates

library(readr)
library(text2vec)
#don't forget to set the working directory or set a path here
dataDirectory = getwd()
threshold = 0.9


#reading the files
print("reading in ...")
#get listing of .txt files in directory
filenames <- list.files(dataDirectory, full.names = T)
#read files into a character vector
files <- lapply(filenames, readLines)
print("done!")

#splitting into articles
print("splitting ...")
split.word <- "Document (.*)"

for (file in files){
  list_alldata_splitted <- str_split(alldata, split.word)[[1]]
  # convert to vector and remove last element (which is a leftover)
  alldata_splitted <- unlist(list_alldata_splitted)
  alldata_splitted <- alldata_splitted[-length(alldata_splitted)]
}

list_alldata_splitted <- str_split(alldata, split.word)
# convert to vector and remove last element (which is a leftover)
alldata_splitted <- unlist(list_alldata_splitted)
alldata_splitted <- alldata_splitted[-length(alldata_splitted)]


print("vectorizing ...")
corpus<-Corpus(VectorSource(alldata_splitted));

#creating term matrix with TF-IDF weighting
terms <-DocumentTermMatrix(corpus,control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE)))

#or compute cosine distance among documents
dissimilarity(tdm, method = "cosine")
print("...done!")

