#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 6;

use FindBin;

use Bootylicious::ArticleIteratorLoader;

use_ok('Bootylicious::ArticleByQueryIterator');

my $i;
my $article;

$i = _new_iterator('unknown');
is $i->size => 0;

$i = _new_iterator('foo');
is $i->first->title          => '<font color="red">Foo</font>';
is_deeply $i->first->content => ['<font color="red">Foo</font>'];
is $i->size                  => 1;

$i = _new_iterator('bar');
is $i->size => 1;

sub _new_iterator {
    Bootylicious::ArticleByQueryIterator->new(
        Bootylicious::ArticleIteratorLoader->new(
            root => "$FindBin::Bin/article-by-query-iterator",
          )->load,
        query => $_[0]
    );
}
