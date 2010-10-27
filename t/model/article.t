#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 25;

use FindBin;
use Bootylicious::Timestamp;

use_ok('Bootylicious::Article');

my $article;

my $pingbacks_path = "$FindBin::Bin/article/20101010-foo.md.pingbacks";

unlink $pingbacks_path;

$article =
  Bootylicious::Article->new(path => "$FindBin::Bin/article/20101010-foo.md");
ok($article);
is $article->pingbacks->size => 0;
ok !$article->has_pingback('http://example.com/hello');
ok $article->comments_enabled;

ok $article->pingback('http://example.com/hello');
is $article->pingbacks->size => 1;
ok $article->has_pingback('http://example.com/hello');
ok -e $pingbacks_path;

unlink $pingbacks_path;

my $comment_path = "$FindBin::Bin/article/20101010-foo.md.comment";

$article->comments->size => 0;

unlink $_ for glob("$comment_path-*");

ok $article->comment(
    author  => 'foo',
    email   => 'foo@example.com',
    content => 'foo bar baz'
);
ok -e "$comment_path-1";
is $article->comments->size => 1;

ok $article->comment(
    author  => 'foo',
    email   => 'foo@example.com',
    content => 'foo bar baz'
);
ok -e "$comment_path-2";
is $article->comments->size => 2;

sleep 1;

ok $article->comment(
    author  => 'foo',
    email   => 'foo@example.com',
    content => 'foo bar baz'
);
ok -e "$comment_path-3";
is $article->comments->size => 3;

is $article->comments->first->number => 1;
is $article->comments->last->number  => 3;

unlink $_ for glob("$comment_path-2");

is $article->comments->size => 2;

ok $article->comment(
    author  => 'foo',
    email   => 'foo@example.com',
    content => 'foo bar baz'
);
ok -e "$comment_path-4";
is $article->comments->size => 3;

unlink $_ for glob("$comment_path-*");

$article =
  Bootylicious::Article->new(
    path => "$FindBin::Bin/article/20101010-no-comments.md");
ok !$article->comments_enabled;
