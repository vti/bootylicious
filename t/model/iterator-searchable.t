#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;

use FindBin;
use Bootylicious::Iterator;

use_ok('Bootylicious::IteratorSearchable');

my $i;

$i =
  Bootylicious::IteratorSearchable->new(
    Bootylicious::Iterator->new(elements => []));
ok not defined $i->find_first(sub { });

$i =
  Bootylicious::IteratorSearchable->new(
    Bootylicious::Iterator->new(elements => [1, 2, 3]));
is $i->find_first(sub { return unless $_[1] == 2; return $_[1] }) => 2;

$i =
  Bootylicious::IteratorSearchable->new(
    Bootylicious::Iterator->new(elements => [1, 2, 3]));
is $i->find_all(sub { return unless $_[1] == 2; return $_[1] })->size => 1;
