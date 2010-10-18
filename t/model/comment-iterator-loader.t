#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 3;

use FindBin;

use Bootylicious::Iterator;
use Bootylicious::Article;

use_ok('Bootylicious::CommentIteratorLoader');

my $iterator = Bootylicious::Iterator->new;
my $loader;

$iterator =
  Bootylicious::CommentIteratorLoader->new(
    root => "$FindBin::Bin/comment-iterator-loader")->load($iterator);
is $iterator->size => 2;

$iterator =
  Bootylicious::CommentIteratorLoader->new(
    path => "$FindBin::Bin/comment-iterator-loader/20101010-foo.md")->load($iterator);
is $iterator->size => 1;
