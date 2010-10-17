#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 8;

use FindBin;

use_ok('Bootylicious::Comment');

my $comment;

$comment = Bootylicious::Comment->new(
    author  => 'foo',
    email   => 'foo@example.com',
    content => 'foo bar baz'
);
ok($comment);

my $path = "$FindBin::Bin/comment/20101010-foo.md.comment-1";
unlink $path;
$comment->create($path);
ok(-e $path);

my $content = do { local $/; open my $fh, '<', $path or die $!; <$fh> };
is $content => "Author: foo\nEmail: foo\@example.com\nUrl: \n\nfoo bar baz";

$comment = Bootylicious::Comment->new;
$comment->load($path);

ok $comment->created;
is $comment->author => 'foo';
is $comment->email => 'foo@example.com';
is $comment->content => 'foo bar baz';

unlink $path;
