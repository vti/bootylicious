#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use lib 't/lib';

use TestController;

use_ok('Bootylicious::Plugin::GoogleAnalytics');

my $ga = Bootylicious::Plugin::GoogleAnalytics->new(urchin => 'foo');

my $c = TestController->new;
$c->res->body('<body></body>');

$ga->hook_finalize($c);
like($c->res->body, qr/google-analytics/);
like($c->res->body, qr/foo/);
