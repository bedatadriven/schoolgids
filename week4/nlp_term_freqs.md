Term frequencies using NLP
================

Constructing Term Frequencies
=============================

Libraries used
--------------

``` r
library(tm)
```

    ## Loading required package: NLP

``` r
library(frogr)
```

    ## Loading required package: zoo

    ## 
    ## Attaching package: 'zoo'

    ## The following objects are masked from 'package:base':
    ## 
    ##     as.Date, as.Date.numeric

    ## Loading required package: Matrix

    ## Loading required package: plyr

``` r
library(Matrix)
```

Downloading the data
--------------------

``` r
datafile <- "schoolgids2017v4_frogged_200.rds"
if(!file.exists(datafile)) {
  download.file("https://storage.googleapis.com/schoolgids/schoolgids2017v4/schoolgids2017v4_frogged_200.rds", datafile)
}
tokens <- readRDS(datafile)
```

The table is a cleaned-up version of the frog output:

``` r
knitr::kable(subset(tokens, school == '16JK00' & sent == 51))
```

|        | school    |    sent|     position| word       | lemma      | pos  |  ner\_index| ner\_type |  chunk\_index| chunk\_type |
|--------|:----------|-------:|------------:|:-----------|:-----------|:-----|-----------:|:----------|-------------:|:------------|
| 733    | 16JK00    |      51|            1| Voor       | voor       | VZ   |          NA| NA        |           471| PP          |
| 734    | 16JK00    |      51|            2| een        | een        | LID  |          NA| NA        |           472| NP          |
| 735    | 16JK00    |      51|            3| kleine     | klein      | ADJ  |          NA| NA        |           472| NP          |
| 736    | 16JK00    |      51|            4| school     | school     | N    |          NA| NA        |           472| NP          |
| 737    | 16JK00    |      51|            5| als        | als        | VG   |          NA| NA        |           473| SBAR        |
| 738    | 16JK00    |      51|            6| de         | de         | LID  |          NA| NA        |           474| NP          |
| 739    | 16JK00    |      51|            7| Saenparel  | Saenparel  | SPEC |          27| MISC      |           474| NP          |
| 740    | 16JK00    |      51|            8| is         | zijn       | WW   |          NA| NA        |           475| VP          |
| 741    | 16JK00    |      51|            9| dat        | dat        | VNW  |          NA| NA        |           476| NP          |
| 742    | 16JK00    |      51|           10| niet       | niet       | BW   |          NA| NA        |           477| ADVP        |
| 743    | 16JK00    |      51|           11| te         | te         | VZ   |          NA| NA        |           478| VP          |
| 744    | 16JK00    |      51|           12| realiseren | realiseren | WW   |          NA| NA        |           478| VP          |
| 745    | 16JK00    |      51|           13| .          | .          | LET  |          NA| NA        |            NA| NA          |
| It con | tains the |  follow|  ing columns| :          |            |      |            |           |              |             |

-   school: the Vestigsnummer of the school
-   sent: the index of the sentence within the school guide
-   position: the index of the token within the sentence
-   word: the original text of the word
-   lemma: the lemmatized version of the token
-   pos: part of speech
-   ner: the index of the named entity within the document, or NA if it is not a named entity
-   ner\_type: the type of named entity
-   chunk\_index: the index of chunk within the document
-   chunk\_type: the type of chunk

Subsetting the token list
=========================

We can select only the nouns from the list of tokens

``` r
noun_tokens <- subset(tokens, tokens$pos == 'N')
nrow(noun_tokens)
```

    ## [1] 671013

The frogr package provides a function for turning

``` r
dtm <- frogr::create_dtm(docs = tokens$school, terms = tokens$lemma)
dtm
```

    ## <<DocumentTermMatrix (documents: 195, terms: 73104)>>
    ## Non-/sparse entries: 486853/13768427
    ## Sparsity           : 97%
    ## Maximal term length: 281
    ## Weighting          : term frequency (tf)
