library(readr)
library(stringr)
library(tm)

splitFactivaFiles <- function(datafolder, writeTemp = FALSE, tempFolder) {
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
  
  articles <- data.frame(unlist(out, recursive = F), stringsAsFactors = F)
  colnames(articles) <- c("articles")
  
  if (writeTemp) {
    dir.create(tempfolder)
    write
  }
  
  #add some ids
  articles$ID <- seq.int(nrow(articles))
}






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

model_tfidf = TfIdf$new()
dtm_tfidf = model_tfidf$fit_transform(dtm)

for(i in seq_along(articles)) {
  

  #get similarities for first document:
  d1_d2_cos_sim = sim2(dtm_tfidf, method = "cosine", norm = "l2")
  #get top 20 mostsimilar (as indices)
  #related_docs_indices = d1_d2_cos_sim.argsort()[:-20:-1]
  
  #see the cosine similarities:
  print(cosine_similarities[related_docs_indices])
  #see which docs... (indexing with 0)
  print(related_docs_indices)
}

library(textreuse)
dir <- system.file("extdata/ats", package = "textreuse")

corpus <- TextReuseCorpus(text = articles$article_clean, tokenizer = tokenize_ngrams, n = 5,
                          progress = FALSE)

comparisons <- pairwise_compare(corpus, jaccard_similarity)




