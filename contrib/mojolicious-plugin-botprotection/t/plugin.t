#!/usr/bin/env perl

use strict;
use warnings;

use Mojo::Client;
use Mojo::IOLoop;
use Test::More;

plan skip_all => 'working sockets required for this test!'
  unless Mojo::IOLoop->new->generate_port;
plan tests => 30;

use Mojolicious::Lite;
use Test::Mojo;

# Silence
#app->log->level('fatal');

# Load plugin
plugin 'bot_protection';

# GET /
get '/' => 'index';

# POST /
post '/' => sub { shift->render_text('Hello') };

# GET /foo
get '/foo' => sub { shift->render_text('Hello') };

# GET /helpers
get '/helpers' => 'helpers';

my $t;

# Dummy field (dummy by default)
$t = Test::Mojo->new;
$t->client(Mojo::Client->new);
$t->post_form_ok('/' => {dummy => 'foo'})->status_is(400)
  ->content_like(qr/bot/);

# POST with GET
$t = Test::Mojo->new;
$t->client(Mojo::Client->new);
$t->post_form_ok('/?foo=bar' => {foo => 'bar'})->status_is(400)
  ->content_like(qr/bot/);

# No cookies
$t = Test::Mojo->new;
$t->client(Mojo::Client->new);
$t->post_form_ok('/' => {foo => 'bar'})->status_is(400)
  ->content_like(qr/bot/);

# Too fast (2s by default)
$t = Test::Mojo->new;
$t->client(Mojo::Client->new);
$t->get_ok('/')->status_is(200);
sleep(1);
$t->post_form_ok('/' => {foo => 'bar'})->status_is(200);
$t->get_ok('/')->status_is(200);
$t->post_form_ok('/' => {foo => 'bar'})->status_is(400)
  ->content_like(qr/bot/);

# Identical fields (50% by default)
$t = Test::Mojo->new;
$t->client(Mojo::Client->new);
$t->get_ok('/')->status_is(200);
sleep(1);
$t->post_form_ok('/' => {foo => 'bar', bar => 'bar', baz => 123})
  ->status_is(200);

$t = Test::Mojo->new;
$t->client(Mojo::Client->new);
$t->get_ok('/')->status_is(200);
$t->post_form_ok('/' => {foo => 'bar', bar => 'bar', baz => 'bar'})
  ->status_is(400)->content_like(qr/bot/);

# Helpers
$t = Test::Mojo->new;
$t->client(Mojo::Client->new);
$t->get_ok('/helpers')->status_is(200)->content_is(<<'EOF');
<input name="dummy" style="display:none" value="" />
EOF

__DATA__

@@ index.html.ep
<%= signed_form_for 'index' => {%>
<%= input_tag 'a', value => 'b' %>
<%}%>

@@ helpers.html.ep
<%= dummy_input %>
