#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 6;

use FindBin;
use Bootylicious::Timestamp;

use_ok('Bootylicious::Article');

my $article;

unlink "$FindBin::Bin/article/20101010-foo.md.pingbacks";

$article =
  Bootylicious::Article->new(path => "$FindBin::Bin/article/20101010-foo.md");
ok($article);
is $article->pingbacks->size => 0;
ok !$article->has_pingback('http://example.com/hello');

$article->pingback('http://example.com/hello');
is $article->pingbacks->size => 1;
ok $article->has_pingback('http://example.com/hello');

unlink "$FindBin::Bin/article/20101010-foo.md.pingbacks";
