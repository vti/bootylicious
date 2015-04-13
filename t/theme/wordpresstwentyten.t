#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 3;
use Mojolicious::Lite;
use Bootylicious;
use File::Temp;

BEGIN { require FindBin; $ENV{MOJO_HOME} = $ENV{BOOTYLICIOUS_HOME} = "$FindBin::Bin"; }
unshift @{app->plugins->namespaces}, 'Bootylicious::Plugin';

my $fh = File::Temp->new();
syswrite($fh, q!{"secret": "secret","theme": "WordpressTwentyten"}!);

plugin 'booty_config' => {file => $fh};
plugin 'model';

get '/' => sub {
	my $self = shift;

    my $timestamp = $self->param('timestamp');

    my $pager = $self->get_articles(timestamp => $timestamp);

    $self->stash(articles => $pager->articles, pager => $pager);

    $self->render_smart('index');
};

use Test::Mojo;

my $t = Test::Mojo->new;

$t->get_ok('/')->status_is(200);
like($t->tx->res->dom->at('#site-generator')->all_text, qr/Wordpress twentyten/i, 'right theme used');
