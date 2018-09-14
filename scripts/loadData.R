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

##read terror organization data, this function also counts the the content of the dictionaries
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

##read GTD data
###################################################################################
loadGTD <- function(baseDirectory){
  # loading original GTD file
  gtd_data <- read_delim(paste0(baseDirectory, "/gtd_13to16_0617dist.txt"), 
                         "\t", escape_double = FALSE, trim_ws = TRUE)
  return(gtd_data)
}

loadGTDcounts <- function(baseDirectory) {
  # reading data from counts file
  gtd_data <- read_csv(paste0(baseDirectory, "/gtd_counts.csv"))
  return(gtd_data)
}

