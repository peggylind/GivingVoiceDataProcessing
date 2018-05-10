library(here)
library(readr)
library(jsonlite)
library(dplyr)
library(stringr)
library(zoo)
library(tm)

options(stringsAsFactors = FALSE)

# Prepare data and secondary data
source(here("scripts","loadData.R")) 
dataDirectory <- "TestData"
secondaryDataDirectory <- "Secondary"
#load the terror organization data
terror_org <- loadTerrorOrganizationData(here(secondaryDataDirectory))

#define list of countries
countries <- c("UK", "US")
#define years and month
years <- c(2014, 2015, 2016)
months <- 1:12

####### PART 1: creation of STATA input file
#create STATA input file
source(here("scripts", "basicStats.R"))
result <- createStataInput(countries, years, month)

#write outputfile
outputFile <- "Output/Data_clean_forStata.csv"
write_csv(result, path=paste0(here(), "/", outputFile))

####### PART 2: creation of topicmodels
source(here("scripts", "topicmodeling.R"))
corpus <- ceaningForTopicmodel()
numberOfTopics = 5
<<<<<<< HEAD
#ldaOut <- runTopicmodel(numberOfTopics)
corpusfordebugging <- runTopicmodel(numberOfTopics)
writeLines(as.character(corpusfordebugging[[2]]))
# #write out results
=======
ldaOut <- runTopicModel(corpus, numberOfTopics)

#write out results
>>>>>>> 9e72cb877566d023f18d02a78760b2a49a4b37ff
outputFolder <- "/Output/"
# #docs to topics
# ldaOut.topics <- as.matrix(topics(ldaOut))
# write.csv(ldaOut.topics,file=paste0(here(), outputFolder, "LDAGibbs",numberOfTopics,"DocsToTopics.csv"))
# # 
# # #top 6 terms in each topic
# ldaOut.terms <- as.matrix(terms(ldaOut,6))
# write.csv(ldaOut.terms,file=paste0(here(), outputFolder, "LDAGibbs",numberOfTopics,"TopicsToTerms.csv"))
# # 
# # #probabilities associated with each topic assignment
# topicProbabilities <- as.data.frame(ldaOut@gamma)
# write.csv(topicProbabilities,file=paste0(here(), outputFolder, "LDAGibbs",numberOfTopics,"TopicProbabilities.csv"))




