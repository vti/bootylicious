#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

plan skip_all => 'working sockets required for this test!'
  unless Mojo::IOLoop->new->generate_port;
plan tests => 18;

BEGIN { require FindBin; $ENV{MOJO_HOME} = "$FindBin::Bin"; }

use lib "$FindBin::Bin/../../contrib/mojo/lib";
use lib "$FindBin::Bin/../../contrib/mojox-validator/lib";
use lib "$FindBin::Bin/../../contrib/mojolicious-plugin-botprotection/lib";

use Mojolicious::Lite;

#app->log->level('fatal');

push @{app->plugins->namespaces}, 'Bootylicious::Plugin';

app->helper(
    config => sub {
        {   articles_directory => 'articles',
            admin              => {username => 'foo', password => 'bar'}
        };
    }
);

plugin 'booty_helpers';
plugin 'model';
plugin 'validator';
plugin 'bot_protection';
plugin 'admin';

use Test::Mojo;

my $t = Test::Mojo->new;

$t->get_ok('/admin')->status_is(302);
$t->get_ok('/admin/login')->status_is(200);
sleep 1;
$t->post_form_ok('/admin/login' => {username => '123', password => '321'})->status_is(200);
sleep 1;
$t->post_form_ok('/admin/login' => {username => 'foo', password => 'bar'})->status_is(302);
$t->get_ok('/admin')->status_is(200);
$t->get_ok('/admin/login')->status_is(404);
$t->get_ok('/admin/logout')->status_is(302);
$t->get_ok('/admin/logout')->status_is(404);
$t->get_ok('/admin/login')->status_is(200);
