SVM and cluster analysis in school terms
================

-   We will continue with the school as the unit of analysis and build on the term-frequency matrices we looked at last week and introduce two machine learning techniques:

-   **Supervised machine learning** works by "training" a model on a set of "labeled" documents.

-   **Clustering** is an unsupervised technique to uncover groups in the datasets

Supervised machine learning
---------------------------

-   Most machine learning algorithms require an input set of features

-   We need to transform the school guides into a matrix of schools and factors

-   Term-frequency matrices are one example of features

-   Machine learning algorithms can be very accurate classifiers, they tend to have low explanatory power.

Training
--------

Load the full(-ish) the pre-computed normalized terms matrix from last week:

``` r
ndtm <- readRDS("schoolgids2017v2_ndtm_v2.rds")
schools <- read.csv("../schools.csv", sep=";", stringsAsFactors = FALSE)
ndtm_meta <- merge(data.frame(VESTIGINGSNUMMER = rownames(ndtm)), schools, all.x = TRUE)
```

The `ndtm` matrix contains a normalized term-frequent matrix for all the schools in our corpus.

``` r
ndtm[1:10, 1:20]
```

    ##         Terms
    ## Docs     aanbevel aanbevol  aanbied aanbieder aanbiedt   aanbod aanbreng
    ##   00AP00 0.000000        0 5.247507  0.000000 0.000000 1.749169 0.000000
    ##   00AR00 0.000000        0 0.000000  0.000000 0.000000 8.219628 0.000000
    ##   00AV00 0.000000        0 2.130833  0.000000 0.000000 8.523333 0.000000
    ##   00BB00 0.000000        0 0.000000  1.600768 1.600768 3.201537 0.000000
    ##   00BW00 0.000000        0 1.137527  1.137527 0.000000 5.687635 0.000000
    ##   00CV00 0.000000        0 0.000000  0.000000 0.000000 9.150805 0.000000
    ##   00DD00 2.046245        0 0.000000  0.000000 0.000000 2.046245 2.046245
    ##   00DN00 7.199424        0 0.000000  0.000000 0.000000 3.599712 0.000000
    ##   00DY00 1.282216        0 1.282216  0.000000 0.000000 0.000000 0.000000
    ##   00DZ00 0.000000        0 5.081301  0.000000 0.000000 1.693767 0.000000
    ##         Terms
    ## Docs     aandacht aandachtsfunctionaris aandachtsgebied aandachtspunt
    ##   00AP00 22.73920                     0               0      1.749169
    ##   00AR00 32.87851                     0               0      1.643926
    ##   00AV00 12.78500                     0               0      0.000000
    ##   00BB00 22.41076                     0               0      0.000000
    ##   00BW00 10.23774                     0               0      0.000000
    ##   00CV00 14.64129                     0               0      0.000000
    ##   00DD00 10.23123                     0               0      0.000000
    ##   00DN00 10.79914                     0               0      0.000000
    ##   00DY00 15.38659                     0               0      2.564431
    ##   00DZ00 25.40650                     0               0      0.000000
    ##         Terms
    ## Docs     aandel  aandoen  aandrag aaneengeslot aang aangaand    aangan
    ##   00AP00      0 0.000000 0.000000     1.749169    0 0.000000  1.749169
    ##   00AR00      0 0.000000 0.000000     1.643926    0 0.000000  3.287851
    ##   00AV00      0 0.000000 0.000000     0.000000    0 0.000000  0.000000
    ##   00BB00      0 0.000000 0.000000     0.000000    0 0.000000  0.000000
    ##   00BW00      0 0.000000 0.000000     0.000000    0 0.000000  0.000000
    ##   00CV00      0 0.000000 0.000000     0.000000    0 1.830161  1.830161
    ##   00DD00      0 0.000000 0.000000     0.000000    0 0.000000  0.000000
    ##   00DN00      0 3.599712 0.000000     0.000000    0 0.000000 10.799136
    ##   00DY00      0 0.000000 0.000000     0.000000    0 0.000000  1.282216
    ##   00DZ00      0 0.000000 1.693767     0.000000    0 3.387534  0.000000
    ##         Terms
    ## Docs       aangat  aangebod
    ##   00AP00 0.000000 10.495015
    ##   00AR00 0.000000  1.643926
    ##   00AV00 0.000000  6.392499
    ##   00BB00 0.000000  1.600768
    ##   00BW00 0.000000  4.550108
    ##   00CV00 0.000000  7.320644
    ##   00DD00 2.046245  0.000000
    ##   00DN00 0.000000  0.000000
    ##   00DY00 0.000000  3.846647
    ##   00DZ00 0.000000  5.081301

-   We will split our sample into a training and testing samples

``` r
training <- sample(nrow(ndtm), size = 500)

predictors <- ndtm[training, ] 
response <- as.factor(ndtm_meta$DENOMINATIE[training])
  
library(e1071)
model <- svm(x = predictors, y = response) 
```

-   Now we can use this model to predict the schools in the test set

``` r
predicted <- predict(model, ndtm[-training, ])

table(predicted)
```

    ## predicted
    ##       Algemeen bijzonder           Antroposofisch Gereformeerd vrijgemaakt 
    ##                        1                        0                        0 
    ##         Hindoe\xefstisch       Interconfessioneel              Islamitisch 
    ##                        0                        0                        0 
    ##                 Openbaar  Protestants-Christelijk           Reformatorisch 
    ##                     1273                      494                        0 
    ##          Rooms-Katholiek    Samenwerking Opb., RK      Samenwerking PC, RK 
    ##                      614                        0                        0

-   Let's see how our model did:

``` r
correct <- predicted == ndtm_meta$DENOMINATIE[-training]
table(correct)
```

    ## correct
    ## FALSE  TRUE 
    ##   810  1572

Let's look at how we did by category:

``` r
table(ndtm_meta$DENOMINATIE[-training], correct)
```

    ##                                 correct
    ##                                  FALSE TRUE
    ##   Algemeen bijzonder               120    1
    ##   Antroposofisch                    22    0
    ##   Evangelisch                        4    0
    ##   Gereformeerd vrijgemaakt          45    0
    ##   Hindoe\xefstisch                   3    0
    ##   Interconfessioneel                 6    0
    ##   Islamitisch                       15    0
    ##   Openbaar                          53  696
    ##   Overige                            1    0
    ##   Protestants-Christelijk          196  393
    ##   Reformatorisch                    37    0
    ##   Rooms-Katholiek                  273  482
    ##   Samenwerking Opb., PC              2    0
    ##   Samenwerking Opb., RK              2    0
    ##   Samenwerking PC, RK               30    0
    ##   Samenwerking PC, RK, Alg. Bijz     1    0
