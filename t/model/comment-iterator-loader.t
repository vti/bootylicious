#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 2;

use FindBin;

use Bootylicious::Iterator;

use_ok('Bootylicious::CommentIteratorLoader');

my $iterator = Bootylicious::Iterator->new;
my $loader;

$iterator =
  Bootylicious::CommentIteratorLoader->new(
    glob => "$FindBin::Bin/comment-iterator-loader/*")->load($iterator);
is $iterator->size => 2;
