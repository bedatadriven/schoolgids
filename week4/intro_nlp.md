Introduction to Natural Language Processing (NLP)
================

In the previous two weeks, we largely looked at the schoolgids corpus using a "bag of words" model. This week, we will delve further into the documents themselves.

The NLP libraries
=================

We will use the NLP package, as well as the openNLP package, which provides access to the Apache OpenNLP toolkit. We will also install Dutch-specific models.

``` r
library(openNLP)
library(NLP)

# install Dutch-language models
#install.packages(c("openNLPmodels.nl", "openNLPmodels.en"), repos = "http://datacube.wu.ac.at/", type = "source") 
```

Now we can use these models to divide text into sentences, and then tag words with their parts of speech.

``` r
# Create a "String" object used by the NLP package

kleuters <- as.String("Bij de kleuters is de ontwikkeling van de grove motoriek heel belangrijk. Met behulp van 
allerlei materialen (klimtoestellen, ballen, stelten, springtouw) leren de kinderen bepaalde 
bewegingen te maken. Vanuit een goed ontwikkelde grove motoriek kan de fijne motoriek 
zich ontwikkelen.")

sentences <- annotate(kleuters,  Maxent_Sent_Token_Annotator(language = "nl"))

## Extract sentences.
kleuters[sentences]
```

    ## [1] "Bij de kleuters is de ontwikkeling van de grove motoriek heel belangrijk."                                                           
    ## [2] "Met behulp van \nallerlei materialen (klimtoestellen, ballen, stelten, springtouw) leren de kinderen bepaalde \nbewegingen te maken."
    ## [3] "Vanuit een goed ontwikkelde grove motoriek kan de fijne motoriek \nzich ontwikkelen."

Parts of Speech
---------------

Part-of-speech annotations are assigned to a single word depending on how it's used in the sentence.

We'll use a part-of-speech annotator from the Apache OpenNLP project trained for the Dutch grammar. The annotator uses standard codes based on the English words for the parts of speech:

| Code | English     | Dutch                 | Example   |
|------|-------------|-----------------------|-----------|
| NN   | Noun        | zelfstandig naamwoord | school    |
| VB   | Verb        | werkwoord             | is        |
| Art  | Article     | artikel               | de, het   |
| Prep | Preposition | voorzetsel            | voor, van |
| Adj  | Adjective   | bijvoeglijk naamwoord | rood      |
| Adv  | Adverb      | bijwoord              | snel      |
| Punc | Punctuation | interpuctie           | . , :     |

``` r
annotations <- annotate(kleuters, list(
            Maxent_Sent_Token_Annotator(language = "nl"),
            Maxent_Word_Token_Annotator(language = "nl"),
            Maxent_POS_Tag_Annotator(language = "nl")))

doc <- AnnotatedPlainTextDocument(kleuters, annotations)

# Access sentences in the document
sents(doc)[1:3]
```

    ## [[1]]
    ##  [1] "Bij"          "de"           "kleuters"     "is"          
    ##  [5] "de"           "ontwikkeling" "van"          "de"          
    ##  [9] "grove"        "motoriek"     "heel"         "belangrijk"  
    ## [13] "."           
    ## 
    ## [[2]]
    ##  [1] "Met"            "behulp"         "van"            "allerlei"      
    ##  [5] "materialen"     "("              "klimtoestellen" ","             
    ##  [9] "ballen"         ","              "stelten"        ","             
    ## [13] "springtouw"     ")"              "leren"          "de"            
    ## [17] "kinderen"       "bepaalde"       "bewegingen"     "te"            
    ## [21] "maken"          "."             
    ## 
    ## [[3]]
    ##  [1] "Vanuit"      "een"         "goed"        "ontwikkelde" "grove"      
    ##  [6] "motoriek"    "kan"         "de"          "fijne"       "motoriek"   
    ## [11] "zich"        "ontwikkelen" "."

We can also inspect the individual "parts of speech" text.

``` r
tagged_words(doc)[1:13]
```

    ## Bij/Prep
    ## de/Art
    ## kleuters/N
    ## is/V
    ## de/Art
    ## ontwikkeling/N
    ## van/Prep
    ## de/Art
    ## grove/Adj
    ## motoriek/N
    ## heel/Adv
    ## belangrijk/Adj
    ## ./Punc

Frog
====

[Frog](http://languagemachines.github.io/frog/) is an advanced Natural Language Processing suite for Dutch, that provides:

-   tokenizaton
-   part-of-speech tagging
-   morphological segmentation
-   depency graph construction
-   chunking
-   named-entity labelling

Compared to OpenNLP:

-   Con: More difficult to install and integrate into workflows
-   Pro: *Far* more sophisticated and complete

Calling Frog
------------

``` r
library(frogr, quietly = TRUE)
```

    ## 
    ## Attaching package: 'zoo'

    ## The following objects are masked from 'package:base':
    ## 
    ##     as.Date, as.Date.numeric

``` r
tokens <- call_frog(as.character(kleuters))
```

    ## Frogging document 1: 288 characters

In constrast to OpenNLP, the frogr package produces a table of tokens. It also includes part of speech tags, but with more detail:

``` r
knitr::kable(tokens[1:13, c("word", "lemma", "morph", "pos")])
```

| word         | lemma        | morph                    | pos                          |
|:-------------|:-------------|:-------------------------|:-----------------------------|
| Bij          | bij          | \[bij\]                  | VZ(init)                     |
| de           | de           | \[de\]                   | LID(bep,stan,rest)           |
| kleuters     | kleuter      | \[kleuter\]\[s\]         | N(soort,mv,basis)            |
| is           | zijn         | \[zijn\]                 | WW(pv,tgw,ev)                |
| de           | de           | \[de\]                   | LID(bep,stan,rest)           |
| ontwikkeling | ontwikkeling | \[ont\]\[wikkel\]\[ing\] | N(soort,ev,basis,zijd,stan)  |
| van          | van          | \[van\]                  | VZ(init)                     |
| de           | de           | \[de\]                   | LID(bep,stan,rest)           |
| grove        | grof         | \[grof\]\[e\]            | ADJ(prenom,basis,met-e,stan) |
| motoriek     | motoriek     | \[motor\]\[iek\]         | N(soort,ev,basis,zijd,stan)  |
| heel         | heel         | \[heel\]                 | ADJ(vrij,basis,zonder)       |
| belangrijk   | belangrijk   | \[belang\]\[rijk\]       | ADJ(vrij,basis,zonder)       |
| .            | .            | \[.\]                    | LET()                        |

The parts-of-speech codes are slightly different than OpenNLP and include more subdivisions. The most complete description of these codes can be found in the paper [Part of Speech Tagging en Lemmatisering](http://www.hum.uu.nl/medewerkers/p.monachesi/papers/vaneynde.pdf).

### Abbreviations used in frog POS

| Dutch generic   | English                |
|:----------------|:-----------------------|
| ADJ             | Adjective              |
| BW              | Adverb                 |
| LET             | Punctuation            |
| LID             | Determiner             |
| N(eigen)        | Proper noun            |
| N(soort)        | Common noun            |
| SPEC(afgebr)    | Partial words          |
| SPEC(onverst)   | Incomprehensible words |
| SPEC(vreemd)    | Foreign words          |
| SPEC(deeleigen) | Part-of-whole words    |
| SPEC(afk)       | Abbreviations          |
| SPEC(symb)      | Symbols                |
| TSW             | Interjection           |
| TW              | Cardinal/ordinal       |
| VG              | Conjunction            |
| VNW             | Pronoun                |
| VZ              | Preposition            |
| WW              | Verb                   |

A quick outline:

-   Substantieven (N): *schoolgebouw*, *vragen*, *gegevens*
-   Adjectieven (ADJ): *belangrijk*, *goed*, *grove*, *fijne*
-   Werkwoorden (WW): *leren*, *is*, *maken*
-   Telwoorden (TW): *zoveel*, *twee*, *24*, *1988*
-   Voornaamwoorden (VNW): *deze*, *ons*, *niemand*, *we*
-   Lidwoorden (LID): *de*, *het*
-   Voorzetsels (VZ): *in*, *tussen*, *op de hoogte*, *ten behoeve van*, *van*
-   Voegwoorden (VG): *en*, *dat*, *of*
-   Bijwoorden (BW): *waarin*, *bijvoorbeeld*, *niet*
-   Tussenwerpsels (TSW): *o*
-   Leestekens (LET): period, comma, quotation marks, etc
-   Speciale tokens (SPEC): bullet points, everything else

Frog further subdivides parts of speech. For example, substantieven are have five properties:

``` r
knitr::kable(tokens[tokens$majorpos == 'N', c("word", "pos")])
```

Chunking
--------

Chunk tags are assigned to groups of words that belong together (i.e. phrases). The most common phrases are the noun phrase (NP, for example the black cat) and the verb phrase (VP, for example is purring) [source](https://www.clips.uantwerpen.be/pages/mbsp-tags).

| **Tag** |      **Description**      |     **Words**    |    **Example**   |
|:-------:|:-------------------------:|:----------------:|:----------------:|
|    NP   |        noun phrase        | DT+RB+JJ+NN + PR | the strange bird |
|    PP   |    prepositional phrase   |       TO+IN      |    in between    |
|    VP   |        verb phrase        |     RB+MD+VB     |    was looking   |
|   ADVP  |       adverb phrase       |        RB        |       also       |
|   ADJP  |      adjective phrase     |     CC+RB+JJ     |   warm and cosy  |
|   SBAR  | subordinating conjunction |        IN        |  whether or not  |
|   PRT   |          particle         |        RP        |   up the stairs  |
|   INTJ  |        interjection       |        UH        |       hello      |

Unfortunately, we have not been able to locate an OpenNLP chunking model for the Dutch language. There has been work in this area, see "Spranger, Kristina & Heid, Ulrich. (2002). A Dutch Chunker as a Basis for the Extraction of Linguistic Knowledge. 93-109" from the conference "Computational Linguistics in the Netherlands."

For this example, we'll look at some text from my high school:

``` r
text <- as.String("The Wellsboro Area School District will prepare all students for lifelong success through excellence in education.")

doc <- AnnotatedPlainTextDocument(text, annotate(text, 
                  list(Maxent_Sent_Token_Annotator(language = "en"),
                        Maxent_Word_Token_Annotator(language = "en"),
                        Maxent_POS_Tag_Annotator(language = "en"),
                        Maxent_Chunk_Annotator(language = "en"))))

chunked_sents(doc)
```

    ## [[1]]
    ## (S
    ##   (NP The/DT Wellsboro/NNP Area/NNP School/NNP District/NNP)
    ##   (VP will/MD prepare/VB)
    ##   (NP all/DT students/NNS)
    ##   (PP for/IN)
    ##   (NP lifelong/JJ success/NN)
    ##   (PP through/IN)
    ##   (NP excellence/NN)
    ##   (PP in/IN)
    ##   (NP education/NN)
    ##   ./.)
