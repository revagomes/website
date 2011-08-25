# Countdown to KO #17: Natural Language Processing with Natural

*This is the 17th in series of posts leading up [Node.js Knockout][1],
and covers using [natural][] in your node app. This post was written
by natural author and [Node.js Knockout judge][2] [Chris Umbel][].*

[1]: http://nodeknockout.com
[natural]: https://github.com/chrisumbel/natural
[2]: http://nodeknockout.com/people/4e516de185bde71148007718
[Chris Umbel]: http://www.chrisumbel.com

"natural" is a general-purpose natural language processing library for
node.js developed principally by [Chris Umbel][]. Various algorithms in
the way of stemming, classification, inflection, and phonetics are
currently supported as well as basic WordNet usage.

At the time of writing "natural" is still young and support for new algorithms
in the aforementioned categories or even other categories still are being
feverishly developed. If you have anything to contribute
[consult the github repository][natural].

This post will walk you through the installation of "natural", consumption of
the various components, and outline the future plans.

# Installation

"natural" is available as an npm and can be installed as such:

    $ npm install natural

# Consumption

## Stemming

Stemming is the processing of taking a word and stripping of affixes down to
the base stem of the word. "natural" currently provides two algorithms for
stemming: the Porter Stemmer and the Lancaster Stemmer.

### Porter Stemmer

The Porter Stemmer was developed in 1979 by
[Martin Porter](http://tartarus.org/~martin/index.html) and was originally
implemented in [BCPL](http://en.wikipedia.org/wiki/BCPL).

This example stems the string "words" to its root "word".

    var stemmer = require('natural').PorterStemmer;
    console.log(stemmer.stem("words"));

This example illustrates a common pattern used throughout "natural". The
`attach()` method patches String to have `stem()` and
`tokenizeAndStem()` helper methods.

The `tokenizeAndStem()` splits the string up on whitespace and
punctuation, removes noise words, and then stems each remaining token
into an array.

    var stemmer = require('natural').PorterStemmer;
    stemmer.attach();
    console.log("i am waking up to the sounds of chainsaws".tokenizeAndStem());
    console.log("chainsaws".stem());

### Lancaster Stemmer

The Lancaster Stemmer (AKA Paice/Husk) algorithm was developed by Chris Paice at
[Lancaster University](http://www.lancs.ac.uk/) with some help by Gareth Husk.
The Lancaster algorithm is somewhat aggressive in its removal of suffixes
resulting is stems that aren't correct spellings of their respective word. If
used for comparison in systems such as full-text searches that's typically
acceptable.

    var stemmer = require('natural').LancasterStemmer;
    console.log(stemmer.stem("words"));
    stemmer.attach();
    console.log("i am waking up to the sounds of chainsaws".tokenizeAndStem());
    console.log("chainsaws".stem());

## Classification

Classification is the process of categorizing texts into predetermined
classes automatically. Before the classification can occur it's
necessary to train the classifier on sample texts.

The only algorithm currently supported for classification in "natural" is Naive
Bayes.

Notice that the training text can either be arrays of tokens or strings. Strings
will be stemmed and have noise words removed so if you want your
training data to be unmodified supply token arrays directly. This example
will output "computing" on the first line and "literature" on the second.

    var natural = require('natural'),
        classifier = new natural.BayesClassifier();

    classifier.train([{classification: 'computing', text: ['fix', 'box']},
        {classification: 'computing', text: 'write some code.'},
        {classification: 'literature', text: ['write', 'script']},
        {classification: 'literature', text: 'read my book'}
    ]);

    console.log(classifier.classify('there is a bug in my code.'));
    console.log(classifier.classify('write a book.'));

## Inflection

"natural" provides inflectors for transforming words. Currently a noun inflector
is provided to pluralize and singularize nouns, a count inflector is provided
to transform integers to their string ordinals i.e. "1st", "2nd", "3rd" and
an experimental present tense verb inflector is provided for
pluralizing/singularizing relevant verbs.

### Noun Inflector

The following example uses the NounInflector to transform the word "beer" to
"beers".

    var natural = require('natural'),
        nounInflector = new natural.NounInflector();

    console.log(nounInflector.pluralize('beer'));
    console.log(nounInflector.singularize('beers'));

Much like the stemmers an `attach()` method exists to patch String to
perform the inflections with `pluralizeNoun()` and `singularizeNoun()`
methods.

    nounInflector.attach();
    console.log('radius'.pluralizeNoun());
    console.log('radii'.singularizeNoun());

### Count Inflector

In this example the CountInflector converts the integers 1, 3 and 111 to "1st",
"3rd" and "111th" respectively.

    var natural = require('natural'),
        countInflector = natural.CountInflector;

    console.log(countInflector.nth(1));
    console.log(countInflector.nth(3));
    console.log(countInflector.nth(111));

### Present Tense Verb Inflector

At the time of writing the PresentVerbInflector is still experimental and
likely does not correctly handle all cases. It is, however, designed to
transform present tense verbs between their singular and plural forms.

    var verbInflector = new natural.PresentVerbInflector();
    console.log(verbInflector.singularize('become'));
    console.log(verbInflector.pluralize('becomes'));

And, of course, the `attach()` method is provided to patch String.

    verbInflector.attach();
    console.log('walk'.singularizePresentVerb());
    console.log('walks'.pluralizePresentVerb());

## Phonetics

"natural" employes two phonetic algorithms to determine if words sound alike,
SoundEx and Metaphone.

### SoundEx

SoundEx is an old algorithm that was originally designed for use in physical
filing systems and was patented in 1918. Despite its age it's been widely
adopted in modern computing to determine if words sound alike.

Here's an example of using "natural"'s implementation.

    var soundEx = require('natural').SoundEx;

    if(soundEx.compare('ruby', 'rubie'))
        console.log('they sound alike');

The raw SoundEx phonetic code can be obtained with the `process()` method. The
following example outputs a cryptic "R100".

    console.log(soundEx.process('rubie'));

Of course an `attach()` method is provided to patch string with helpers.
Note that the `tokenizeAndPhoneticize()` method splits a string up into
words, and returns an array of phonetic codes.

    console.log('phonetics'.phonetics());
    console.log('phonetics rock'.tokenizeAndPhoneticize());

    if('ruby'.soundsLike('rubie'))
        console.log('they sound alike');

### Metaphone

"natural" also implements the Metaphone phonetic algorithm which is
considerably newer (developed in 1990 by Lawrence Philips) and more robust than
SoundEx. Its implementation in "natural" mirrors SoundEx.

    var metaphone = require('natural').Metaphone;

    if(metaphone.compare('ruby', 'rubie'))
        console.log('they sound alike');

    metaphone.attach();

    console.log('phonetics'.phonetics());
    console.log('phonetics rock'.tokenizeAndPhoneticize());

    if('ruby'.soundsLike('rubie'))
        console.log('they sound alike');

## WordNet

A new and somewhat experimental feature of "natural" is WordNet database
integration. WordNet organizes English words into synsets (groups of synonyms),
and contains example sentences and definitions.

### Lookup

Consider the following example which looks up all entries for the
word "node" in WordNet.

Note the path parameter passed in to the WordNet constructor. That's the path
where the WordNet database files are to be stored. If the files do not exist
"natural" will download them for you.

    var natural = require('natural'),
        wordnet = new natural.WordNet('.');

    wordnet.lookup('node', function(results) {
        results.forEach(function(result) {
            console.log('------------------------------------');
            console.log(result.synsetOffset);
            console.log(result.pos);
            console.log(result.lemma);
            console.log(result.pos);
            console.log(result.gloss);
        });
    });

### Synonyms

In this example a list of synonyms are retrieved for the first result of a
lookup via the `getSynonyms()` method.

    var natural = require('natural'),
        wordnet = new natural.WordNet('.');

    wordnet.lookup('entity', function(results) {
        wordnet.getSynonyms(results[0], function(results) {
            results.forEach(function(result) {
                console.log('------------------------------------');
                console.log(result.synsetOffset);
                console.log(result.pos);
                console.log(result.lemma);
                console.log(result.pos);
                console.log(result.gloss);
            });
        });
    });

# Future Plans

While "natural" has a reasonable amount of functionality at this point it has
quite a way to go to make it to the level of projects like Python's [Natural
Language Toolkit](http://www.nltk.org/).

To make up that gap in the short term plans are in the works to implement
part of speech (pos) tagging, the double-metaphone phonetic algorithm, and a
maximum entropy classifier.

In the longer term extending "natural" beyond English is a hope, but will
require additional expertise.

If you have the interest to help out
[please do so](https://github.com/chrisumbel/natural)!
