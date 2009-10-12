#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use Mojolicious;
use Mojo::Transaction::Single;
use Mojolicious::Controller;

use_ok('Bootylicious::Plugin::GoogleAnalytics');

my $ga = Bootylicious::Plugin::GoogleAnalytics->new(urchin => 'foo');

my $c = Mojolicious::Controller->new(
    tx  => Mojo::Transaction::Single->new,
    app => Mojolicious->new
);

$c->app->log->level('error');

$c->res->body('<body></body>');

$ga->hook_finalize($c);
like($c->res->body, qr/google-analytics/);
like($c->res->body, qr/foo/);
