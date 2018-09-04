createStataInput <- function(countries, years, month) {
  #placeholder for output
  output <- data.frame()
  
  #create by year and month
  for (year in years) {
    for (month in months) {
      #load data
      #find files for particular month, year
      filePattern <- paste0(year, "_", month, "[[:blank:]][[:digit:]]{1,4}")
      filenames <- list.files(dataDirectory,pattern=filePattern, full.names = T)
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
        for (i in 1:nrow(terror_org)) {
          terror_organization <- terror_org[i,]
          #occurances for each dictionary
          occ <- length(grep(terror_organization$dict, docs$content))
          #counts for each dictionary
          count <- sum(str_count(docs$content, terror_organization$dict))
          # merge with terror organizations to keep all info together
          # add rows to output
          output <- rbind(output, data.frame(country, terror_organization$ID, 
            terror_organization$name, terror_organization$name_gtd, terror_organization$dict, terror_organization$count_dict, 
                 year, month, terror_organization$size, occ, count))
        }
      }
    }
  }
  
  # sort by country and dictionary and calculate 3-month lag occurances and counts
  output_sorted <- output %>%
    #sort
    arrange(terror_organization.ID, country) %>%
    #add ID column 
    rownames_to_column(var = "rowid") %>%
    #group by 
    group_by(country, terror_organization.dict) %>% 
    #calculate 3-month lag occurances and counts
    mutate(occ_lag3 = rollsumr(occ, k = 3, fill = NA), 
           count_lag3 = rollsumr(count, k = 3, fill = NA)) %>%
    #shift calculated lages down
    mutate(occ_lag3=lag(occ_lag3), count_lag3=lag(count_lag3)) 
  
  return(output_sorted)
}

createGDTcounts <- function(gtd_data, years, write = TRUE) {
  gtd_sorted <- gtd_data %>% 
    #filter for the terror organizations and years
    filter(gname %in% terror_org$name_gtd & iyear %in% years) %>% 
    select(gname, iyear, imonth, region, nkill, nkillus) %>%
    # group by year, month and terror organization
    group_by(iyear, imonth, gname) %>% 
    # create counts
    summarise(sum_nkill = sum(nkill, na.rm = TRUE),
              count_attacks = n(),
              sum_reg = sum(nkill[region==1 | region==8], na.rm = TRUE),
              count_attacks_reg = length(gname[region==1 | region==8])) %>%
    # sort according to terror organization
    arrange(factor(gname, levels = terror_org$name_gtd))
    
  # write file 
  if (write) {
    write_csv(gtd_sorted, path=paste0(secondaryDataDirectory, "/gtd_counts.csv"))
  }        
  return(gtd_sorted)
}
  