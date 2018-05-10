createStataInput <- function(countries, years, month) {
  #placeholder for output
  output <- data.frame()
  
  #create by year and month
  for (year in years) {
    for (month in months) {
      #load data
      #find files for particular month, year
      filePattern <- paste0(year, "_", month, "[[:blank:]][[:digit:]]{1,4}")
      filenames <- list.files(here(dataDirectory),pattern=filePattern, full.names = T)
      #read files into a character vector
      files <- lapply(filenames, readLines)
      #create small corpus
      docssmall<- Corpus(VectorSource(files))
      
      #create by country
      for (country in countries) {
        #loading the match pattern for the country
        matchPattern <- loadPattern(here(secondaryDataDirectory), country)
        #filter only for country specified in pattern
        docs<- docssmall[which(grepl(matchPattern, docssmall$content))]
        #convert everything to lower case
        docs<- tm_map(docs, content_transformer(tolower))
        
        #create by terror organization
        for (dict in terror_org$dict) {
          #occurances for each dictionary
          occ <- length(grep(dict, docs$content))
          #counts for each dictionary
          count <- sum(str_count(docs$content, dict))
          #add rows to output
          output <- rbind(output, data.frame(country, dict, year, month, occ, count))
        }
      }
    }
  }
  
  # sort by country and dictionary and calculate 3-month lag occurances and counts
  output_sorted <- output %>%
    #sort
    arrange(dict, country) %>%
    #add ID column 
    mutate(ID = rownames(output_sorted))
    #group by 
    group_by(country, dict) %>% 
    #calculate 3-month lag occurances and counts
    mutate(occ_lag3 = rollsumr(occ, k = 3, fill = NA), 
           count_lag3 = rollsumr(count, k = 3, fill = NA)) %>%
    #shift calculated lages down
    mutate(occ_lag3=lag(occ_lag3), count_lag3=lag(count_lag3)) 
  
  # merge with terror organizations to keep all info together
  
  
  return(output_sorted)
}
  