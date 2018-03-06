Introduction to Natural Language Processing (NLP)
================

-   [The NLP libraries](#the-nlp-libraries)
    -   [Parts of Speech](#parts-of-speech)
-   [Frog](#frog)
    -   [Calling Frog](#calling-frog)
    -   [Parts-of-Speech Tagging](#parts-of-speech-tagging)
        -   [Abbreviations used in frog POS](#abbreviations-used-in-frog-pos)
        -   [Substantieven](#substantieven)
    -   [Chunking](#chunking)
    -   [Named-Entity Recognition](#named-entity-recognition)
    -   [Lemitization](#lemitization)
    -   [Parsing](#parsing)

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

sentences <- NLP::annotate(kleuters,  Maxent_Sent_Token_Annotator(language = "nl"))

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
annotations <- NLP::annotate(kleuters, list(
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

Before calling frog from R, you must have a frog server running.

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

Parts-of-Speech Tagging
-----------------------

In constrast to OpenNLP, the frogr package produces a table of tokens. It also includes part of speech tags, but with more detail:

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

| Code | Part of Speech | Example                                        |
|------|----------------|------------------------------------------------|
| N    | Substantieven  | schoolgebouw, vragen, gegevens                 |
| ADJ  | Adjectieven    | belangrijk, goed, grove, fijne                 |
| WW   | Werkwoorden    | leren, is, maken                               |
| TW   | Telwoorden     | zoveel, twee, 24, 1988                         |
| VNW  | Voornaamwoordn | deze, ons, niemand, we                         |
| LID  | Lidwoorden     | zoveel, twee, 24, 1988                         |
| VZ   | Voorzetsels    | in, tussen, op de hoogte, ten behoeve van, van |
| VG   | Voegwoorden    | en, dat, of                                    |
| BW   | Bijwoorden     | waarin, bijvoorbeeld, niet                     |
| TSW  | Tussenwerpsels | o                                              |
| LET  | Leestekens     | period, comma, quotation marks, etc            |
| SPEC | Special tokens | Everything else !                              |

Frog further subdivides parts of speech. For details on these subdivisions, see the paper referenced above. But it is worth briefly looking at the additional properties of *substantieven* as an example.

### Substantieven

*Substantieven*, or nouns, have up to five additional properties provided by frog:

``` r
knitr::kable(tokens[tokens$majorpos == 'N', c("word", "pos")])
```

|     | word           | pos                         |
|-----|:---------------|:----------------------------|
| 3   | kleuters       | N(soort,mv,basis)           |
| 6   | ontwikkeling   | N(soort,ev,basis,zijd,stan) |
| 10  | motoriek       | N(soort,ev,basis,zijd,stan) |
| 15  | behulp         | N(soort,ev,basis,onz,stan)  |
| 18  | materialen     | N(soort,mv,basis)           |
| 20  | klimtoestellen | N(soort,mv,basis)           |
| 22  | ballen         | N(soort,mv,basis)           |
| 24  | stelten        | N(soort,mv,basis)           |
| 26  | springtouw     | N(soort,ev,basis,zijd,stan) |
| 30  | kinderen       | N(soort,mv,basis)           |
| 32  | bewegingen     | N(soort,mv,basis)           |
| 41  | motoriek       | N(soort,ev,basis,zijd,stan) |
| 45  | motoriek       | N(soort,ev,basis,zijd,stan) |

#### N-Type

The first property distinguishes between *soortbepalende* (soort) en *individualiserende* (eigen) substantieven. In English, these types are called "common nouns" and "proper nouns".

-   **eigen**: Names of people, places, and things that are normally capitalized.
-   **soort**: All other nouns.

#### Getal

The second property distinguishes between the singular and plural forms of nouns.

-   **ev**: enkelvoud (singular)
-   **mv**: meervouden (plural)

#### Graad

Tags nouns in their diminutive form (dimin) or (basis)

> Diminutiefvormen zijn gemarkeerd door een suffix (-je, -tje, -pje, -ke, ...). Bij afwezigheid van het suffix wordt de waarde ‘basis’ toegekend; die waarde wordt ook toegekend aan de substantieven die geen diminutiefvorm kunnen hebben (gebergte, vee). Substantieven die steeds een diminutiefsuffix hebben (ootje, nippertje) krijgen de waarde ‘diminutief’, behalve wanneer ze niet het typisch diminutieve kenmerk van onzijdigheid vertonen, d.w.z. wanneer ze —in het enkelvoud— niet combineren met het/dat/dit/ons maar met de/die/deze/onze; dat is soms het geval bij persoonsnamen, als in die/?dat Nelleke toch.

#### Genus

> Bij POS tagging maken we alleen het onderscheid tussen zijdige en onzijdige substantieven; de verdere differentiatie van de zijdige substantieven in masculiene en feminiene wordt dus niet gemaakt. De zijdige substantieven zijn die welke in het enkelvoud determiners nemen als de/die/deze/onze, terwijl de onzijdige determiners nemen als het/dat/dit/ons. In combinaties als de laatste drie jaar en om de vier uur krijgen jaar en uur ondanks de aanwezigheid van de toch hun gebruikelijke waarde onzijdig. Het lidwoord is hier namelijk niet het zijdige enkelvoudige de maar het meervoudige de.

#### Namvaal

-   Standaard (nominatief, oblique)
-   Genatief ("*ouders* taak")

Chunking
--------

Chunk tags are assigned to groups of words that belong together (i.e. phrases).

The most common phrases are the noun phrase (NP, for example the black cat) and the verb phrase (VP, for example is purring) [source](https://www.clips.uantwerpen.be/pages/mbsp-tags).

``` r
tokens <- call_frog("De Martin Luther Kingschool biedt de kinderen een brede ontwikkeling. Het onderwijs is             
zodanig ingericht dat naast de cognitieve ook de sociaal-emotionele, de creatieve en de             
motorische ontwikkeling gestimuleerd worden.")
```

    ## Frogging document 1: 245 characters

``` r
knitr::kable(tokens[, c("word", "pos", "chunk")])
```

| word                       | pos                                               | chunk            |
|:---------------------------|:--------------------------------------------------|:-----------------|
| De                         | LID(bep,stan,rest)                                | B-NP             |
| Martin\_Luther\_Kingschool | SPEC(deeleigen)\_SPEC(deeleigen)\_SPEC(deeleigen) | I-NP\_I-NP\_I-NP |
| biedt                      | WW(pv,tgw,met-t)                                  | B-VP             |
| de                         | LID(bep,stan,rest)                                | B-NP             |
| kinderen                   | N(soort,mv,basis)                                 | I-NP             |
| een                        | LID(onbep,stan,agr)                               | B-NP             |
| brede                      | ADJ(prenom,basis,met-e,stan)                      | I-NP             |
| ontwikkeling               | N(soort,ev,basis,zijd,stan)                       | I-NP             |
| .                          | LET()                                             | O                |
| Het                        | LID(bep,stan,evon)                                | B-NP             |
| onderwijs                  | N(soort,ev,basis,onz,stan)                        | I-NP             |
| is                         | WW(pv,tgw,ev)                                     | B-VP             |
| zodanig                    | ADJ(vrij,basis,zonder)                            | B-ADJP           |
| ingericht                  | WW(vd,vrij,zonder)                                | I-ADJP           |
| dat                        | VG(onder)                                         | B-SBAR           |
| naast                      | VZ(init)                                          | B-PP             |
| de                         | LID(bep,stan,rest)                                | B-NP             |
| cognitieve                 | ADJ(prenom,basis,met-e,stan)                      | I-NP             |
| ook                        | BW()                                              | B-ADVP           |
| de                         | LID(bep,stan,rest)                                | B-NP             |
| sociaal-emotionele         | ADJ(nom,basis,met-e,zonder-n,stan)                | I-NP             |
| ,                          | LET()                                             | O                |
| de                         | LID(bep,stan,rest)                                | B-NP             |
| creatieve                  | ADJ(prenom,basis,met-e,stan)                      | I-NP             |
| en                         | VG(neven)                                         | B-CONJP          |
| de                         | LID(bep,stan,rest)                                | B-NP             |
| motorische                 | ADJ(prenom,basis,met-e,stan)                      | I-NP             |
| ontwikkeling               | N(soort,ev,basis,zijd,stan)                       | I-NP             |
| gestimuleerd               | WW(vd,vrij,zonder)                                | B-VP             |
| worden                     | WW(inf,vrij,zonder)                               | I-VP             |
| .                          | LET()                                             | O                |

Named-Entity Recognition
------------------------

``` r
knitr::kable(tokens[1:5, c("word", "pos", "ner")])
```

| word                       | pos                                               | ner                 |
|:---------------------------|:--------------------------------------------------|:--------------------|
| De                         | LID(bep,stan,rest)                                | O                   |
| Martin\_Luther\_Kingschool | SPEC(deeleigen)\_SPEC(deeleigen)\_SPEC(deeleigen) | B-PER\_I-PER\_I-PER |
| biedt                      | WW(pv,tgw,met-t)                                  | O                   |
| de                         | LID(bep,stan,rest)                                | O                   |
| kinderen                   | N(soort,mv,basis)                                 | O                   |

Frog supports several types of Named entities:

-   Person (PER)
-   Organization (ORG)
-   Location (LOC)
-   Product (PRO)
-   Event (EVE)
-   Miscellaneous (MISC)

Lemitization
------------

Lemitization is a more sophisticated version of stemming based on dictionaries and parts of speech tagging.

``` r
knitr::kable(tokens[1:5, c("word", "majorpos", "lemma")])
```

| word                       | majorpos | lemma                      |
|:---------------------------|:---------|:---------------------------|
| De                         | LID      | de                         |
| Martin\_Luther\_Kingschool | SPEC     | Martin\_Luther\_Kingschool |
| biedt                      | WW       | bieden                     |
| de                         | LID      | de                         |
| kinderen                   | N        | kind                       |

The lemmatized form is defined as follows: \* For nouns, the lemma is the singular form \* For verbs, the lemma is the infinitive

Parsing
-------

Frog also includes a dependency parser, which attempts to understand the sentence.

``` r
tokens <- call_frog("Onze school is blauw")
```

    ## Frogging document 1: 20 characters

``` r
knitr::kable(tokens[, c("position", "word", "majorpos", "parse1", "parse2")])
```

|  position| word   | majorpos |  parse1| parse2 |
|---------:|:-------|:---------|-------:|:-------|
|         1| Onze   | VNW      |       2| det    |
|         2| school | N        |       3| su     |
|         3| is     | WW       |       0| ROOT   |
|         4| blauw  | ADJ      |       3| predc  |
