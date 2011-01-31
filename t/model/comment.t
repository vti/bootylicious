#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 3;

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
