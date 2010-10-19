#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 5;

use FindBin;

use Bootylicious::ArticleIteratorLoader;

use_ok('Bootylicious::ArticleByTagIterator');

my $i;
my $article;

$i = _new_iterator('unknown');
is $i->size => 0;

$i = _new_iterator('foo');
is $i->size => 1;

$i = _new_iterator('bar');
is $i->size => 2;

$i = _new_iterator('baz');
is $i->size => 1;

sub _new_iterator {
    Bootylicious::ArticleByTagIterator->new(
        Bootylicious::ArticleIteratorLoader->new(
            root => "$FindBin::Bin/article-by-tag-iterator"
          )->load,
        tag => $_[0]
    );
}
