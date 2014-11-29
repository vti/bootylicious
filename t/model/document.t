#!/usr/bin/env perl

use strict;
use warnings;

use utf8;

use Test::More tests => 21;

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
    path => "$FindBin::Bin/documents/20101010T121314-foo-bar-baz.pod");
ok $document;
is $document->created->timestamp => '20101010T12:13:14';
is $document->created->year      => '2010';
is $document->created->month     => '10';
ok $document->modified;
is $document->name    => 'foo-bar-baz';
is $document->format  => 'pod';
is $document->content => qq/Foo and bar.\n\nAnd buzz!\n/;

my $path = "$FindBin::Bin/documents/20101010-foo.md";
unlink $path;

$document = Bootylicious::Document->new;
$document->author('foo');
$document->content('foo bar baz');
$document->create($path);
ok(-e $path);

my $content = do { local $/; open my $fh, '<', $path or die $!; <$fh> };
is $content => "Author: foo\n\nfoo bar baz";

$document = Bootylicious::Document->new;
$document->load($path);

ok $document->created;
is $document->author  => 'foo';
is $document->content => 'foo bar baz';

$document->author('bar');
$document->content('bar bar foo');

$document->update;

$document = Bootylicious::Document->new;
$document->load($path);

ok $document->created;
is $document->author  => 'bar';
is $document->content => 'bar bar foo';

$document->delete;

$document = Bootylicious::Document->new;
ok not defined $document->load($path);
ok !-e $path;
