library(readr)
library(stringr)
library(tm)

# put the name of data folder
datafolder <- "/Users/plindner/OneDrive - University Of Houston/CACDS/Lea Hellmueller/Testdata_origFactiva"
filelist <- list.files(datafolder, pattern = "*.txt", recursive = T, full.names = T)


# create placeholder for file vector

out <- vector("list", length= length(filelist))

# read the data
for (f in seq_along(filelist)) {
  singlefile <- read_file(filelist[f])
  # split up into individual documents
  split.word <- "Document [A-Z]+[0-9]+[a-z]+[0-9]+[a-z]+" 
  list_filedata_splitted <- str_split(singlefile, split.word)
  out[[f]] <- unlist(list_filedata_splitted)
}

#add some ids
articles <- data.frame(unlist(out, recursive = F), stringsAsFactors = F)
colnames(articles) <- c("articles")
articles$ID <- seq.int(nrow(articles))


prep_fun = function(x) {
  x %>% 
    # make text lower case
    str_to_lower %>% 
    # remove non-alphanumeric symbols
    str_replace_all("[^[:alnum:]]", " ") %>% 
    # collapse multiple spaces
    str_replace_all("\\s+", " ")
}
articles$article_clean = prep_fun(articles$articles)

it = itoken(articles$article_clean, progressbar = FALSE)
v = create_vocabulary(it) %>% prune_vocabulary(doc_proportion_max = 0.1, term_count_min = 5)
vectorizer = vocab_vectorizer(v)

dtm = create_dtm(it, vectorizer)
dim(dtm)
