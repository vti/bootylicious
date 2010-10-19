#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 7;

use FindBin;
use Bootylicious::ArticleIteratorLoader;

use_ok('Bootylicious::TagCloud');

my $cloud;
my $tag;

$cloud =
  Bootylicious::TagCloud->new(articles =>
      Bootylicious::ArticleIteratorLoader->new(root => "$FindBin::Bin/tags")
      ->load);

$tag = $cloud->next;
is $tag->name  => 'bar';
is $tag->count => 2;

$tag = $cloud->next;
is $tag->name  => 'baz';
is $tag->count => 1;

$tag = $cloud->next;
is $tag->name  => 'foo';
is $tag->count => 1;
