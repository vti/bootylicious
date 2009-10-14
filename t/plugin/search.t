#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use lib 't/lib';

use TestController;

use_ok('Bootylicious::Plugin::Search');

my $search = Bootylicious::Plugin::Search->new();

my $c = TestController->new;

ok(!$c->app->routes->children->[0]);
$search->hook_init($c->app);
is($c->app->routes->children->[0]->name, 'search');

$search->_search($c);

sub config {}

sub get_articles {}
