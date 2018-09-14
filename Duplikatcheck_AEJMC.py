#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  duplicate_check_primitive.py
#  
#  Copyright 2017 ma <ma@maT530>

'''the aim is to read in files from a given folder and filter out duplicates

in this primitive version we just use a tfidf vectorizer to compare the 
documents

this works OK, but will blow up your computer if done that way (all similarities at once)
with 18k documents ... so the code below is changed to do it iteratively


example call:
ma@maT530:~/climate_change_data$ time python3 scripts/duplicate_check_vectorizer.py Artikel_Climate_Change/ 0.8 > T0.8.result.txt

this took on my computer around 



then for example grep:
#how many documents have similars above the threshold:
grep -P 'DOC1' T0.8.result.txt | sort | uniq | wc -l

#
grep -P 'DOC1|DOC2' T0.8.result.txt

OR
better output the sets of similar ones as you like


updates TK 2017-12-05
+write csv
+threshold 
+encoding in write


'''




import os
import csv

from sklearn.feature_extraction.text import TfidfVectorizer

folder_with_files = "C:/Users/vhase/Desktop/Data"
threshold = 0.9

documents_as_strings = []
document_lookup_table = {}

print("reading in ...")
for index, curr_file in enumerate(os.scandir(folder_with_files)):
    print("reading ", curr_file.path)
    with open(curr_file.path, "r", encoding='utf-8', errors='replace') as art_file:
        documents_as_strings.append(art_file.read())
    #if we wanna find it by the index ... see below
    document_lookup_table[index] = curr_file.name 
        
print("done!")

print("vectorizing ...")
#here we set some thresholds to 
vect = TfidfVectorizer(min_df=2, # if set to 1, it's less general ... less near-duplicates won't be found ...
                        max_df=0.8,
                        #ngram_range=(1, 2), ... not even needed
                        )
tfidf = vect.fit_transform(documents_as_strings)
print("...done!")

#that will kill your machine ...
#pairwise_similarity = (tfidf * tfidf.T).A
#pairwise_similarity = (tfidf * tfidf.T)
#print(pairwise_similarity)

#do it iteratively ...
from sklearn.metrics.pairwise import linear_kernel

similarity_counter= 0 


writer = csv.writer(open("C:/Users/vhase/Desktop/Data/results.csv", 'w'))

with open('results.txt', 'w', encoding="utf-8") as csvfile:
    for i in range(len(documents_as_strings)):
        #get similarities for first document:
        cosine_similarities = linear_kernel(tfidf[i], tfidf).flatten()
        #get top 20 most similar (as indices)
        related_docs_indices = cosine_similarities.argsort()[:-20:-1]
        #see the cosine similarities:
        print(cosine_similarities[related_docs_indices])
        #see which docs... (indexing with 0)
        print(related_docs_indices)
    
        #now your turn ... if some of those are above X then ....
        for index, sim in enumerate(cosine_similarities[related_docs_indices]):
            if i == related_docs_indices[index]:
                #print("this is a comparison with itself; not interesting")
                continue
            else:
                if sim > threshold:
                    print("similarity is above the threshold: {}".format(sim))
                    writer.writerow({format(sim)}) #tk
                    #this is the document for which we want to find the "neighbours"
                    doc1 = documents_as_strings[i]
                    #this document is one that scores high in similarity
                    doc2 = documents_as_strings[related_docs_indices[index]]
                
                    print("---"*20)
                    print("DOC1 ({})".format(document_lookup_table[i]))
                    print(doc1[:200])
                    print("___"*20)
                    writer.writerow({format(document_lookup_table[i])})
                    print("DOC2 to compare: ({})".format(document_lookup_table[related_docs_indices[index]]))
                    print(doc2[:200])
                    print("---"*20)
                    writer.writerow({format(document_lookup_table[related_docs_indices[index]])})
                
                    similarity_counter += 1

#attention: this will overshoot because it counts several documents several times
#for proper evaluation put all documents_with_similarities into a set ... or count 
#the ones that have similars (symmetric relations ...)                
print(similarity_counter)
