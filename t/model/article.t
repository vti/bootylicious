#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 14;

use FindBin;

use_ok('Bootylicious::Article');

my $article;

eval {
    Bootylicious::Article->new(
        path => "$FindBin::Bin/articles/unlikely-to-exist");
};
ok $@;

eval { Bootylicious::Article->new(path => "$FindBin::Bin/articles/junk"); };
ok $@;

$article = Bootylicious::Article->new(
    path    => "$FindBin::Bin/articles/20101010T12:13:14-foo-bar-baz.pod",
    parsers => {
        pod => sub { $_[0] }
    }
);
ok $article;
is $article->created->timestamp => '20101010T12:13:14';
is $article->created->year      => '2010';
is $article->created->month     => '10';
ok $article->modified;
is $article->name        => 'foo-bar-baz';
is $article->ext         => 'pod';
is $article->title       => 'Foo bar baz!';
is_deeply $article->tags => [qw/foo bar baz/];
is $article->preview     => "Foo and bar.\n\n";
is $article->content => qq/Foo and bar.\n\n<a name="cut"><\/a>\nAnd buzz!\n/;
