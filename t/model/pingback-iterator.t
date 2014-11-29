#!/usr/bin/env perl

use strict;
use warnings;

use utf8;

use Test::More tests => 9;

use FindBin;

use_ok('Bootylicious::PingbackIterator');

my $i;

$i =
  Bootylicious::PingbackIterator->new(
    path => "$FindBin::Bin/pingback-iterator/unknown");
ok($i);
is $i->size => 0;

$i =
  Bootylicious::PingbackIterator->new(
    path => "$FindBin::Bin/pingback-iterator/20101010-empty.md.pingbacks");
ok($i);
is $i->size => 0;

$i =
  Bootylicious::PingbackIterator->new(
    path => "$FindBin::Bin/pingback-iterator/20101010-foo.md.pingbacks");
ok($i);
is $i->size => 2;

is $i->next->source_uri => 'http://example.com/hello';
is $i->next->source_uri => 'http://example2.com/foo';
