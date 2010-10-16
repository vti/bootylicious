#!/usr/bin/env perl

use strict;
use warnings;

use utf8;

use Test::More tests => 6;

use FindBin;
use Bootylicious::PingbackIterator;

use_ok('Bootylicious::PingbackIteratorFinder');

my $i;
my $finder;
my $pingback;

$i =
  Bootylicious::PingbackIterator->new(
    path => "$FindBin::Bin/pingback-iterator/20101010-empty.md.pingbacks");
ok($i);

$finder = Bootylicious::PingbackIteratorFinder->new(iterator => $i);
ok not defined $finder->find('http://example.com/hello');

$i =
  Bootylicious::PingbackIterator->new(
    path => "$FindBin::Bin/pingback-iterator/20101010-foo.md.pingbacks");
ok($i);

$finder = Bootylicious::PingbackIteratorFinder->new(iterator => $i);
ok not defined $finder->find('http://example.com/hello2');
ok $finder->find('http://example.com/hello');
