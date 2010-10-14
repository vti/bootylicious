#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 6;

use FindBin;
use Bootylicious::ArticleIterator;

use_ok('Bootylicious::ArticleArchive');

my $archive;
my $year;

$archive =
  Bootylicious::ArticleArchive->new(
    articles => Bootylicious::Iterator->new(elements => []));
ok not defined $archive->next;

$archive =
  Bootylicious::ArticleArchive->new(articles =>
      Bootylicious::ArticleIterator->new(root => "$FindBin::Bin/archive"));

$year = $archive->next;
is $year->{year}           => 2006;
is $year->{articles}->size => 1;

$year = $archive->next;
is $year->{year}           => 2005;
is $year->{articles}->size => 2;
