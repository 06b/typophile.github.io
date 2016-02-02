#!/usr/bin/env perl
#
# The MIT License (MIT)
# 
# Copyright (c) 2016 Simon Cozens (@simoncozens)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

use URI::Escape;
use LWP::Simple;
use File::Basename;
use File::Path;

sub key2url {
    my $key = shift;
    my ($host, $path) = split /\)/, $key;
    $host = join ".", reverse(split/,/, $host);
    return $host.$path;
}

while (<>) {
    chomp;
    my $url = key2url($_);
    print($url. " -> ");
    if (-e $url.".html") {
        print "[DOWNLOADED, SKIPPING]\n";
        next;
    }
    my $result = get("http://web.archive.org/cdx/search/cdx?fl=urlkey,timestamp&url=".uri_escape($url));
    get_non_broken_version($result);
}

sub get_non_broken_version {
    my $result = shift;
    my @rows = split /\n/, $result;
    for (reverse @rows) { # From latest to oldest
        chomp;
        my ($urlkey, $ts) = split /\s+/, $_;
        next if $ts >= 20150601000000; # Or whenever they broke it
        my $url = key2url($urlkey);
        mkpath(dirname($url));
        my $archiveurl = "http://web.archive.org/$ts/".uri_escape("http://".$url);
        print $archiveurl."\n";
        getstore($archiveurl, $url.".html");
        return;
    }
}
