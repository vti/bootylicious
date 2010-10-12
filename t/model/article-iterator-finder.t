#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 14;

use FindBin;
use Bootylicious::ArticleIterator;

use_ok('Bootylicious::ArticleIteratorFinder');

my $article;

my $iterator =
  Bootylicious::ArticleIterator->new(root => "$FindBin::Bin/finder");

$article =
  Bootylicious::ArticleIteratorFinder->new(iterator => $iterator)
  ->find(2010, 1, 'unknown');
ok not defined $article;

$iterator->rewind;
$article =
  Bootylicious::ArticleIteratorFinder->new(iterator => $iterator)
  ->find(2010, 1, 'foo');
ok $article;
is $article->name => 'foo';
ok not defined $article->next;
is $article->prev->name => 'bar';

$iterator->rewind;
$article =
  Bootylicious::ArticleIteratorFinder->new(iterator => $iterator)
  ->find(2010, 2, 'bar');
ok $article;
is $article->name       => 'bar';
is $article->prev->name => 'baz';
is $article->next->name => 'foo';

$iterator->rewind;
$article =
  Bootylicious::ArticleIteratorFinder->new(iterator => $iterator)
  ->find(2010, 3, 'baz');
ok $article;
is $article->name => 'baz';
ok not defined $article->prev;
is $article->next->name => 'bar';
