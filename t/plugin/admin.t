#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

plan tests => 18;

BEGIN { require FindBin; $ENV{MOJO_HOME} = $ENV{BOOTYLICIOUS_HOME} = "$FindBin::Bin"; }

use Mojolicious::Lite;

push @{app->plugins->namespaces}, 'Bootylicious::Plugin';

plugin 'booty_config' => {
    default => {
        articles_directory => 'articles',
        secret => 'secret',
        plugins => [admin => {username => 'foo', password => 'bar'}]
    }
};
plugin 'model';

use Test::Mojo;

my $t = Test::Mojo->new;

$t->get_ok('/admin')->status_is(302);
$t->get_ok('/admin/login')->status_is(200);
sleep 1;
$t->post_ok('/admin/login', form => {username => '123', password => '321'})->status_is(200);
sleep 1;
$t->post_ok('/admin/login', form => {username => 'foo', password => 'bar'})->status_is(302);
$t->get_ok('/admin')->status_is(200);
$t->get_ok('/admin/login')->status_is(404);
$t->get_ok('/admin/logout')->status_is(302);
$t->get_ok('/admin/logout')->status_is(404);
$t->get_ok('/admin/login')->status_is(200);
