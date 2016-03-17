# typophile.github.io

This repo contains a simple read-only copy of typophile, reconstructed with love. 

[Typophile](https://en.wikipedia.org/wiki/Typophile_(Internet_forum)) was a fantastic type design web forum started in 2000 that ran until 2015. 
It was a cornucopia of type design and font engineering trivia, with threads on every important development in the field in the period. 
But it was often overrun with spam, and after 6 months of total shutdown it seems, sadly, not likely to come back any time soon. 

In response to the typophile tragedy, during January 2016 Simon Cozens of SILE fame developed a script to download an archive from the [Archive.org Wayback Machine](https://web.archive.org) and Dave Crossland worked with him to convert the raw material into this site. 

## How you can help

1. Look out for places where details have not been picked up (e.g. Commenters' names.) and [open an issue](https://github.com/typophile/typophile.github.io/issues). 
   To help bring the details back, use the "view original" link to look at the original HTML and figure out a CSS selector which identified them so they can be picked up.

2. Suggest ways to improve the design of the website and improve the usability, by [opening an issue](https://github.com/typophile/typophile.github.io/issues)

3. Let everyone know about the most important discussion threads, by posting links to them along with a note about why they are important to [issue #4](https://github.com/typophile/typophile.github.io/issues/4)

4. Figure out how to extract 2nd or later discussion pages, [Issue #2](https://github.com/typophile/typophile.github.io/issues/2)

5. Review and contribute to any other [open issues](https://github.com/typophile/typophile.github.io/issues/)

## Obtaining the HTML files

The Wayback Machine has a number of APIs, one of which is the [CDX Server API](https://github.com/internetarchive/wayback/tree/master/wayback-cdx-server).
This lists all URIs archived from a given site, and can be called on typophile like this:

    curl 'http://web.archive.org/cdx/search/cdx?url=*.typophile.com&fl=urlkey,timestamp' > urls.txt ;

This will take a couple of minutes, and will return the complete list of all 471,100 URLs that it knows about. 
Since there are 1,796 duplicates we can remove them:

    awk '{print $1}' urls.txt | sort | uniq > urls-unique.txt ;

To get the forum discussion pages, run

    grep '/node/' urls-unique.txt | grep -v cms | grep -v crss | perl wayback-typophile.pl

The script creates a `typophile.com` directory with a copy of each page, as it was the last time it was archived before it got wiped. The contents of this directory come to around 1.3Gb of data, and so are not included in this repository.

## Extracting the content

The next stage is to parse and index this content. Use `rake convert` to turn the `typophile.com` directory into a directory full of JSON files. The output of this process is included in the repository for convenience.

## Indexing the content

You now need an Elasticsearch server, and the [elasticsearch-fileimport](https://github.com/codecentric/elasticsearch-fileimport) tool. Build the importer with `mvn` and copy the resulting JAR file into this directory. Then run `rake reindex`. (If you are using Homebrew, you may first need to add the following to `file_import_settings.yml`:

    cluster:
        name: elasticsearch_youruserid

)

## Serving the content

The Typophile articles are then available through a front-end search interface written in [Sinatra](http://www.sinatrarb.com). Install Sinatra (`bundle install` should do all that) and then run `thin start`. Hey presto, you have your own Typophile archive.

* * * 

> The phrase ‘democratization of typography’ has become common, referring to the wide availability of the tools of production for type and typographic design. 
> One may take this with some scepticism: after all, for the majority, the generation and production of these tools is still largely in the hands of a few corporations — though the [software freedom] movement may provide an alternative. 
> The watchwords remain: doubt, critique, reason, hope.

Robin Kinross, "Modern Typography" (2004, p.182, the final page.)
