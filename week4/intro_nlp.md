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
zich ontwikkelen. 
Bij deze ontwikkeling van de fijne motoriek worden materialen gebruikt, die belangrijk zijn 
voor de voorbereiding van het schrijven zoals (insteek)mozaïek, klei, puzzels, vouwbladen, 
vlechtwerk en borduurwerk. In groep 2 worden voorbereidende schrijfoefeningen gedaan. 
Voor het schrijfonderwijs gebruiken wij de methode: “Novoskript”. 
Het doel van het schrijven is te komen tot een handschrift dat duidelijk en goed leesbaar is, 
en met een schrijftempo en vormgeving die passen bij het kind. In de hoogste leerjaren gaan 
de kinderen meer een eigen weg om hun handschrift te ontwikkelen. 
Het is mogelijk om motorische remedial teaching te geven voor het handschrift en te 
onderzoeken of er speciaal schrijfgerei nodig is.")


sentences <- annotate(kleuters,  Maxent_Sent_Token_Annotator(language = "nl"))

## Extract sentences.
kleuters[sentences]
```

    ## [1] "Bij de kleuters is de ontwikkeling van de grove motoriek heel belangrijk."                                                                                                                                            
    ## [2] "Met behulp van \nallerlei materialen (klimtoestellen, ballen, stelten, springtouw) leren de kinderen bepaalde \nbewegingen te maken."                                                                                 
    ## [3] "Vanuit een goed ontwikkelde grove motoriek kan de fijne motoriek \nzich ontwikkelen."                                                                                                                                 
    ## [4] "Bij deze ontwikkeling van de fijne motoriek worden materialen gebruikt, die belangrijk zijn \nvoor de voorbereiding van het schrijven zoals (insteek)mozaïek, klei, puzzels, vouwbladen, \nvlechtwerk en borduurwerk."
    ## [5] "In groep 2 worden voorbereidende schrijfoefeningen gedaan."                                                                                                                                                           
    ## [6] "Voor het schrijfonderwijs gebruiken wij de methode: “Novoskript”."                                                                                                                                                    
    ## [7] "Het doel van het schrijven is te komen tot een handschrift dat duidelijk en goed leesbaar is, \nen met een schrijftempo en vormgeving die passen bij het kind."                                                       
    ## [8] "In de hoogste leerjaren gaan \nde kinderen meer een eigen weg om hun handschrift te ontwikkelen."                                                                                                                     
    ## [9] "Het is mogelijk om motorische remedial teaching te geven voor het handschrift en te \nonderzoeken of er speciaal schrijfgerei nodig is."

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

Dealing with Full Documents
---------------------------

``` r
text <- as.String("
Leerplicht  
In een aantal gevallen kunnen kinderen worden vrijgesteld van leerplicht. Dit noemen wij 
verlof. Kinderen hoeven voor een dag of voor een beperkt aantal dagen dan niet naar school. 
Het is de verantwoordelijkheid van de ouders om terughoudend om dit verlof aan te vragen. 
Vraag niet meer verlof aan dan echt noodzakelijk. In het algemeen is het niet in het belang 
van het kind school te moeten missen.
 
5.2. De uitdagende leeromgeving 
 
De leerlingen hebben niet altijd vaste werkplekken. De werkplekken kunnen worden 
aangepast aan de behoeften van de leerlingen. De groepen hebben zo de mogelijkheid om 
hoeken in de klassen te creëren, terwijl de hogere groepen eventueel kunnen worden 
ingericht als flexibele werk- en onderzoekruimtes. Tevens geven een aantal eigentijdse 
methodes invulling aan de leeromgeving. In iedere groep zijn er hoeken gecreëerd om te 
kunnen samen leren, zelf leren en leren leren. 
 
Didactische uitgangspunten  
• Wij werken vanuit concrete leerlijnen, leerdoelen en leerstrategieën  
• Leerkrachten dagen kinderen uit zich verder te ontwikkelen  
• Leerkrachten creëren een rijke leeromgeving  
• Kinderen leren vanuit succeservaringen. Hierop is de begeleiding van de leerkracht gericht  
• De leerling is medeverantwoordelijk voor het eigen leerproces  
• De leerkracht stelt zich op als begeleider en leider van de leerling  
")

sannot <- annotate(text, Maxent_Sent_Token_Annotator(language = "nl", probs = TRUE))


doc <- AnnotatedPlainTextDocument(text, annotate(text, 
                  list(Maxent_Sent_Token_Annotator(language = "nl",),
                        Maxent_Word_Token_Annotator(language = "nl"),
                        Maxent_POS_Tag_Annotator(language = "nl"))))
```