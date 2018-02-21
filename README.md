# Text Mining for Education Research Course

This reposistory contains presentations and analyses for a intensive six-week course in
text mining with R, focused on the corpus of Dutch School Guides.

## Corpus

A corpus of 2915 PDF _schoolgids_ from Dutch _bassisscholen_ were acquired by crawling the 
websites listed in DUO's [addressen van alle schoolvestigingen in het basisonderwijs](https://duo.nl/open_onderwijsdata/databestanden/po/adressen/adressen-po-3.jsp).

A custom [scraper](scrape.R) was written locate links to PDFs on basisschool websites and 
to handle some of the peculiarieties of websites in this sector.

Next, text was [extracted](extractText.R) from each of the 2974 PDFs that successfully downloaded
using the pdftools package, and compiled into a `VCorpus` object suitable for use with the tm package:

* [Full Corpus](https://storage.googleapis.com/schoolgids/schoolgids2017v4/schoolgids2017v4.rds) (103 mb)

* [500 school sample](https://storage.googleapis.com/schoolgids/schoolgids2017v4/schoolgids2017v4_500.rds) (18 mb)

* [100 school sample](https://storage.googleapis.com/schoolgids/schoolgids2017v4/schoolgids2017v4_100.rds) (3.5 mb)

## Week 1

Topics covered:

* Introduction to R

* Regular Expressions

Sample analyses:

* Extracting school year from School Guide URL

## Week 2

Topics covered:

* Term Document Matrices

* Writing Functions in R

Sample analyses:

* [Constructing a normalized term frequencies matrix](week2/term-frequencies.md)

* [Finding correlations between textual terms and CITO scores](week2/correlations_cito.md)

## Week 3

Topics covered:

* Tokenizing by n-gram

* SVM, cluster analysis

* Data visualization with ggplot

Sample analyses:

* [SVM and cluster analysis in school terms](week3/ml_school_terms.md)

## Week 4

Topics covered:

* [Natural Language Processing (NLP)](week4/intro_nlp.md)

Sample analyses:

* [Extracting parental contribution information](week4/ouderbijdrage.md)

## Week 5

Topics covered:

* Topic Modeling
