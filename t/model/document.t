#!/usr/bin/env perl

use strict;
use warnings;

use utf8;

use Test::More tests => 19;

use FindBin;

use_ok('Bootylicious::Document');

my $document;

eval {
    Bootylicious::Document->new(
        path => "$FindBin::Bin/documents/unlikely-to-exist")->name;
};
ok $@;

eval {
    Bootylicious::Document->new(path => "$FindBin::Bin/documents/junk")->name;
};
ok $@;

$document =
  Bootylicious::Document->new(
    path => "$FindBin::Bin/documents/20101010T12:13:14-foo-bar-baz.pod");
ok $document;
is $document->created->timestamp => '20101010T12:13:14';
is $document->created->year      => '2010';
is $document->created->month     => '10';
ok $document->modified;
is $document->name    => 'foo-bar-baz';
is $document->format  => 'pod';
is $document->content => qq/Foo and bar.\n\nAnd buzz!\n/;

$document =
  Bootylicious::Document->new(
    path => "$FindBin::Bin/documents/20100601-привет.md");
ok $document;
is $document->created->timestamp => '20100601T00:00:00';
is $document->created->year      => '2010';
is $document->created->month     => '6';
ok $document->modified;
is $document->name   => 'привет';
is $document->format => 'md';
is $document->content =>
  qq/Это все юникод. Ляляля.\nА вот и сказочки конец.\n/;
