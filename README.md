# tft team comp recommender ⚔️

## table of contents

* [summary](#summary)
* [setup](#setup)

## summary

the tft team recommender app is a prolog project that was built for cpsc312 project 2. it's a command-line app that asks the user a set of questions to determine the best team comp for the user's board, given its current state. it takes the following features into account when determining the recommendations:
- roll type (slow roll, default, etc)
- difficulty
- units
- items
- augments

upon completion of the quiz, the app will display the recommendations at three different levels of detail!

the app also employs a python script to scrape tft team comp data from online and convert it into a .csv file. a prolog script then converts the .csv file into a prolog database that the app can then use for its recommendations. feel free to add your own comps to the files!

## setup

### prerequisites 

1) [`prolog`](https://www.swi-prolog.org/) must be installed on your device. 
2) [`swipl`](https://www.swi-prolog.org/) must also be installed on your device. it can be installed during the installation of [`prolog`].
3) [optional] [`python`](https://www.python.org/) must be installed on your device to run the scraping script.

clone or download/unzip the repository and open it in a command-line interface. run the following command to download the project dependencies:

```
swipl tft_recommender.pl
```

this will load the app into prolog. to properly use the app, data needs to be loaded from the .csv files. this can be done by doing the following:

```
?- setup.
```

to run the recommendation app, input either of the following:

```
?- r.
?- recommend.
```

## stack
for the prolog app:
- prolog
- swipl

for the scraping script:
- python 3.9
- beautifulsoup
- selenium
- pandas