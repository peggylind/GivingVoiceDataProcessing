library(here)
library(readr)
library(jsonlite)
library(dplyr)
library(tibble)
library(stringr)
library(zoo)
library(tm)

options(stringsAsFactors = FALSE)

# Use this script to control the steps by running is individual parts
# this means you usually wouldn't source this file and simply only run the parts that you need

# load the scripts
source(here("scripts","preprocessing.R"))
source(here("scripts","loadData.R"))
source(here("scripts", "basicStats.R"))
source(here("scripts", "topicmodeling.R"))

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Part A: Preprocessing (only neceesary for raw Factiva data)
# location of the raw Factiva data folder
#datafolder <- "/Users/plindner/OneDrive - University Of Houston/CACDS/Lea Hellmueller/Testdata_origFactiva"
# read origial Factiva files and split into articles
#splitFactivaFiles(datafolder, writeTemp = T, tempFolder = here("splittedArticles"))
# remove duplicates

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Part B: prepare and load secondary data (or create GTD data)
# define where to find the secondary data
secondaryDataDirectory <- "Secondary"

#define list of countries
countries <- c("US, UK")
#define years and month
years <- c(2014, 2015, 2016)
months <- 1:12

# Part B1: load the terror organization data
terror_org <- loadTerrorOrganizationData(here(secondaryDataDirectory))

# PART B2: creation of GTD (Global Terrorist Database) counts
# checks if counts already have been created (this potentially avoids reading the GTD file
# but make sure you have generated the counts for the years)
if (file.exists(paste0(secondaryDataDirectory, "/gtd_counts.csv"))) {
  gtd_counts <- loadGTDcounts(here(secondaryDataDirectory))
} else {
  gtd_data <- loadGTD(here(secondaryDataDirectory))
  gtd_counts <- createGDTcounts(gtd_data, years, write = TRUE)
}


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Part C: creation of STATA input file
# define where to find the clean files with articles
dataDirectory <- "Data_clean"
# create counts from articles
result <- createStataInput(countries, years, month)
# merge with GTD count and data
result <- left_join(result, gtd_counts, 
                   by = c("terror_organization.name_gtd" = "gname", "month" = "imonth", "year" = "iyear"))

# write outputfile in format ready for STATA processing
outputFile <- "Output/Data_clean_forStata.csv"
write_csv(result, path=paste0(here(), "/", outputFile))


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Part E: creation of topicmodels
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




