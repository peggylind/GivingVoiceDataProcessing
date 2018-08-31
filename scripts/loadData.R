##read all article files into corpus
###################################################################################
loadCorpusData <- function(dataDirectory){
  
  #get listing of .txt files in directory
  filenames <- list.files(dataDirectory, pattern="*.txt", full.names = T)
  #read files into a character vector
  files <- lapply(filenames, readLines)
  
  #create corpus from vector
  docs_ges<- Corpus(VectorSource(files))

  return(docs_ges)
}

##read terror organization data
###################################################################################
loadTerrorOrganizationData <- function(baseDirectory){
  result <- fromJSON(txt = paste0(baseDirectory, "/terror_organizations.json"))
  result_tbl <- as_data_frame(result)
  # count dictionaries content
  result_tbl$count_dict <- sapply(result_tbl$dict, function(x) length(unlist(str_split(x, "\\|"))))
  return(result_tbl)
}

##read pattern to identify media by country
###################################################################################
loadPattern <- function(baseDirectory, pattern){
  result <- fromJSON(txt = paste0(baseDirectory, "/patterns.json"))
  result_tbl <- as_data_frame(result)
  strmatchingPattern <- pull(result_tbl, pattern)
  return(strmatchingPattern)
}