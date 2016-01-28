# typophile.github.io

This repo contains a simple read-only copy of typophile, reconstructed with love. 

[Typophile](https://en.wikipedia.org/wiki/Typophile_(Internet_forum)) was a fantastic type design web forum started in 2000 that ran until 2015. 
It was a cornucopia of type design and font engineering trivia, with threads on every important development in the field in the period. 
But it was often overrun with spam, and after 6 months of total shutdown it seems, sadly, not likely to come back any time soon. 

In response to the typophile tragedy, during January 2016 Simon Cozens of SILE fame developed a script to download an archive from the [Archive.org Wayback Machine](https://web.archive.org) and Dave Crossland worked with him to convert the raw material into this site. 


The Wayback Machine has a number of APIs, one of which is the [CDX Server API](https://github.com/internetarchive/wayback/tree/master/wayback-cdx-server).
This lists all URIs archived from a given site, and can be called on typophile like this:

    curl 'http://web.archive.org/cdx/search/cdx?url=*.typophile.com&fl=urlkey,timestamp' > urls.txt ;

This will take a couple of minutes, and will return the complete list of all 471,100 URLs that it knows about. 
Since there are 1,796 duplicates we can remove them:

    awk '{print $1}' urls.txt | sort | uniq > urls-unique.txt ;

However, this is not a complete list of all snapshots for each URI, but just the most recent.
For instance, the entry for `com,typophile)/wiki/oblique` was `20150630000942` - the update that replaced everything with the "come back soon" page.

So we need to ask the CDX server about each particular URI to get a master list of all archived pages. 
For the oblique wiki page example, that would be like:

    curl 'http://web.archive.org/cdx/search/cdx?url=typophile.com/wiki/oblique&fl=urlkey,timestamp' ;
    com,typophile)/wiki/oblique 20120728022207
    ...
    com,typophile)/wiki/oblique 20150630000942

So, to download a copy of the last non-broken version of every typophile page from the wayback machine, we need a small script to convert each `urlkey` back into a URL and do a CDX search with that URL. 
[wayback-typophile.pl](wayback-typophile.pl) is such a script. 
To get the forum discussion pages, run

    grep node urls-unique.txt > nodes.txt
    ./wayback-typophile.pl < nodes.txt ;
    typophile.com/cms/crss/node/56291 -> http://web.archive.org/20090331224652/http%3A%2F%2Ftypophile.com%2Fcms%2Fcrss%2Fnode%2F56291
    typophile.com/cms/crss/node/56297 -> http://web.archive.org/20090331065320/http%3A%2F%2Ftypophile.com%2Fcms%2Fcrss%2Fnode%2F56297
    typophile.com/cms/crss/node/56319 -> http://web.archive.org/20090331223924/http%3A%2F%2Ftypophile.com%2Fcms%2Fcrss%2Fnode%2F56319

The script creates a `typophile.com` directory with a copy of each page, as it was the last time it was archived before it got wiped. 

The next step is to finish converting these raw materials into clean MarkDown, and a Jeykll site to publish them nicely on the web.

* * * 

> The phrase ‘democratization of typography’ has become common, referring to the wide availability of the tools of production for type and typographic design. 
> One may take this with some scepticism: after all, for the majority, the generation and production of these tools is still largely in the hands of a few corporations — though the [software freedom] movement may provide an alternative. 
> The watchwords remain: doubt, critique, reason, hope.

Robin Kinross, "Modern Typography" (2004, p.182, the final page.)