#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 7;

use FindBin;

use_ok('Bootylicious::Comment');

my $comment;

$comment = Bootylicious::Comment->new(
    author  => 'foo',
    email   => 'foo@example.com',
    content => 'foo bar baz'
);
ok($comment);

is $comment->content => 'foo bar baz';

$comment = Bootylicious::Comment->new(content => '[quote]Foo[/quote]');
is $comment->content => '<blockquote>Foo</blockquote>';

$comment = Bootylicious::Comment->new(content => '[quote]Foo');
is $comment->content => '<blockquote>Foo</blockquote>';

$comment = Bootylicious::Comment->new(content => '[code]Foo[/code]');
is $comment->content => '<code>Foo</code>';

$comment = Bootylicious::Comment->new(content => '[code]Foo');
is $comment->content => '<code>Foo</code>';
