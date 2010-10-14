#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 3;

use Mojolicious::Lite;
use Test::Mojo;

push @{app->plugins->namespaces}, 'Bootylicious::Plugin';
plugin google_analytics => {urchin => 'foo'};

# Silence
app->log->level('error');

get '/' => 'index';

my $t = Test::Mojo->new;

$t->get_ok('/')->status_is(200)->content_like(qr/google-analytics/);

__DATA__
@@ index.html.ep
<body>
foo
</body>
