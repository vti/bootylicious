#!/usr/bin/env perl

use strict;
use warnings;

use utf8;

use Test::More tests => 6;

use FindBin;

use_ok('Bootylicious::DocumentIterator');

my $documents;
my $document;

$documents =
  Bootylicious::DocumentIterator->new(root => "$FindBin::Bin/documents");
is $documents->size => 4;

$document = $documents->next;
is $document->name => 'foo-bar-baz';

$document = $documents->next;
is $document->name => 'привет';

$document = $documents->next;
is $document->name => 'hello';

$document = $documents->next;
is $document->name => 'last';
