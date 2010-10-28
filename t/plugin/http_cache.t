#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

plan skip_all => 'working sockets required for this test!'
  unless Mojo::IOLoop->new->generate_port;
plan tests => 10;

BEGIN {
    use FindBin;
    $ENV{MOJO_HOME} = "$FindBin::Bin/../";
}

use lib "$FindBin::Bin/../../contrib/mojo/lib";

use Mojolicious::Lite;
use Mojo::ByteStream 'b';

app->log->level('fatal');

push @{app->plugins->namespaces}, 'Bootylicious::Plugin';

plugin 'http_cache';

any '/' => 'index';

use Test::Mojo;

my $t = Test::Mojo->new;

my $etag = b("Hello\n")->md5_sum;

$t->get_ok('/')->status_is(200)->header_is('ETag' => $etag)
  ->content_like(qr/Hello/);

$t->get_ok('/', {'If-None-Match' => $etag})->status_is(304)->content_is('');
$t->post_ok('/', {'If-None-Match' => $etag})->status_is(200)->content_is("Hello\n");

__DATA__
@@ index.html.ep
Hello
