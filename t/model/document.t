#!/usr/bin/env perl

use strict;
use warnings;

use utf8;

use Test::More tests => 25;

use FindBin;

use_ok('Bootylicious::Document');

my $document;

eval {
    Bootylicious::Document->new(
        path => "$FindBin::Bin/documents/unlikely-to-exist");
};
ok $@;

eval { Bootylicious::Document->new(path => "$FindBin::Bin/documents/junk"); };
ok $@;

$document = Bootylicious::Document->new(
    path    => "$FindBin::Bin/documents/20101010T12:13:14-foo-bar-baz.pod",
    parsers => {
        pod => sub { $_[0] }
    }
);
ok $document;
is $document->created->timestamp => '20101010T12:13:14';
is $document->created->year      => '2010';
is $document->created->month     => '10';
ok $document->modified;
is $document->name        => 'foo-bar-baz';
is $document->ext         => 'pod';
is $document->title       => 'Foo bar baz!';
is_deeply $document->tags => [qw/foo bar baz/];
is $document->preview     => "Foo and bar.\n\n";
is $document->content => qq/Foo and bar.\n\n<a name="cut"><\/a>\nAnd buzz!\n/;

$document = Bootylicious::Document->new(
    path    => "$FindBin::Bin/documents/20100601-привет.md",
    parsers => {
        md => sub { $_[0] }
    }
);
ok $document;
is $document->created->timestamp => '20100601T00:00:00';
is $document->created->year      => '2010';
is $document->created->month     => '6';
ok $document->modified;
is $document->name        => 'привет';
is $document->ext         => 'md';
is $document->title       => 'Заголовок';
is_deeply $document->tags => [qw/раз два три/];
is $document->preview     => "Это все юникод. Ляляля.\n\n";
is $document->content =>
  qq/Это все юникод. Ляляля.\n\n<a name="cut"><\/a>\nА вот и сказочки конец.\n/;
