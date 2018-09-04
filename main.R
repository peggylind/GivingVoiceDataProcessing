library(here)
library(readr)
library(jsonlite)
library(dplyr)
library(tibble)
library(stringr)
library(zoo)
library(tm)

options(stringsAsFactors = FALSE)

# Prepare data and secondary data
source(here("scripts","loadData.R")) 
dataDirectory <- "Data_clean"
secondaryDataDirectory <- "Secondary"
#load the terror organization data
terror_org <- loadTerrorOrganizationData(here(secondaryDataDirectory))

#define list of countries
countries <- c("UK")
#define years and month
years <- c(2014, 2015, 2016)
months <- 1:12

####### PART 1: creation of GTD (Global Terrorist Database) counts
# checks if counts already have been created (this potentially avoids reading the GTD file
# but make sure you have generated the counts for the years)
if (file.exists(paste0(secondaryDataDirectory, "/gtd_counts.csv"))) {
  gtd_counts <- loadGTDcounts(here(secondaryDataDirectory))
} else {
  gtd_data <- loadGTD(here(secondaryDataDirectory))
  gtd_counts <- createGDTcounts(gtd_data, years, write = TRUE)
}


####### PART 2: creation of STATA input file
#create STATA input file
source(here("scripts", "basicStats.R"))
result <- createStataInput(countries, years, month)
#merge with GTD counts
result <- left_join(result, gtd_counts, 
                   by = c("terror_organization.name_gtd" = "gname", "month" = "imonth", "year" = "iyear"))


#write outputfile
outputFile <- "Output/Data_clean_forStata_UK.csv"
write_csv(result, path=paste0(here(), "/", outputFile))

####### PART 2: creation of topicmodels
source(here("scripts", "topicmodeling.R"))
corpus <- cleaningForTopicmodel()
numberOfTopics = 5
ldaOut <- runTopicmodel(numberOfTopics)

# #write out results
ldaOut <- runTopicModel(corpus, numberOfTopics)

#write out results
outputFolder <- "/Output/"
#docs to topics
ldaOut.topics <- as.matrix(topics(ldaOut))
write.csv(ldaOut.topics,file=paste0(here(), outputFolder, "LDAGibbs",numberOfTopics,"DocsToTopics.csv"))

# #top 6 terms in each topic
ldaOut.terms <- as.matrix(terms(ldaOut,6))
write.csv(ldaOut.terms,file=paste0(here(), outputFolder, "LDAGibbs",numberOfTopics,"TopicsToTerms.csv"))
#
# #probabilities associated with each topic assignment
topicProbabilities <- as.data.frame(ldaOut@gamma)
write.csv(topicProbabilities,file=paste0(here(), outputFolder, "LDAGibbs",numberOfTopics,"TopicProbabilities.csv"))




