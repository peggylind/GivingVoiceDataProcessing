library(topicmodels)
library(SnowballC)

cleaningForTopicmodel <- function() {
  
  #load data and create corpus for all articles
  allCorpus <- loadCorpusData(here(dataDirectory))
  
  #Cleaning - preprocessing
  
  #create the toSpace content transformer 
  toSpace <- content_transformer(function(x, pattern) { return (gsub(pattern, " ", x))})
  #to remove potentially problematic symbols
  allCorpus <- tm_map(allCorpus, toSpace, "-")
  allCorpus <- tm_map(allCorpus, toSpace, ":")
  allCorpus <- tm_map(allCorpus, toSpace, "'")
  allCorpus <- tm_map(allCorpus, toSpace, "'")
  allCorpus <- tm_map(allCorpus, toSpace, " -")
  
  #Remove punctuation - replace punctuation marks with " "
  allCorpus <- tm_map(allCorpus, removePunctuation)
  
  #Transform to lower case
  allCorpus <-tm_map(allCorpus,content_transformer(tolower))
  
  #Strip digits
  allCorpus <- tm_map(allCorpus, removeNumbers)
  
  #Remove stopwords from standard stopword list 
  allCorpus <- tm_map(allCorpus, removeWords, stopwords("english"))
  
  #define and eliminate all custom stopwords
  myStopwords <- c("can", "say","one","way","use",
                   "also","howev","tell","will",
                   "much","need","take","tend","even",
                   "like","particular","rather","said",
                   "get","well","make","ask","come","end",
                   "first","two","help","often","may",
                   "might","see","someth","thing","point",
                   "post","look","right","now","think","‘ve ",
                   "‘re ","anoth","put","set","new","good",
                   "want","sure","kind","larg","yes,","day","etc",
                   "quit","sinc","attempt","lack","seen","awar",
                   "littl","ever","moreov","though","found","abl",
                   "enough","far","earli","away","achiev","draw",
                   "last","never","brief","bit","entir","brief",
                   "great","lot")
  allCorpus <- tm_map(allCorpus, removeWords, myStopwords)
  
  #Strip whitespace?
  allCorpus <- tm_map(allCorpus, stripWhitespace)
  
  #Stem document
  allCorpus <- tm_map(allCorpus,stemDocument)
  
  #some clean up
  allCorpus <- tm_map(allCorpus, content_transformer(gsub),
                      pattern = "wouldn'", replacement = "wouldnot")
  
  return(allCorpus)
}

runTopicmodel <- function(corpus, numberOfTopics, burnin = 4000, iter = 2000,
  thin = 500, nstart = 5, best = TRUE) {
  
  #SAUBER AB HIER
  #Create document-term matrix
  dtm <- DocumentTermMatrix(corpus)
  
  #Run LDA using Gibbs sampling
  #seed <-list(2003,5,63,100001,765)
  #ldaOut <-LDA(dtm,numberOfTopics, method="Gibbs", control=list(nstart=nstart, seed = seed, best=best, burnin = burnin, iter = iter, thin=thin))
  
  return(allCorpus)
  #return(ldaOut)
}

