#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 7;

use Mojo::Client;

use FindBin;
require "$FindBin::Bin/../bootylicious.pl";

my $app = app();
$app->log->level('fatal');

my $client = Mojo::Client->new->app($app);

# Index page
$client->get(
    '/' => sub {
        my ($self, $tx) = @_;

        is($tx->res->code, 200);
    }
)->process;

$client->get(
    '/index' => sub {
        my ($self, $tx) = @_;

        is($tx->res->code, 200);
    }
)->process;

# Index rss page
$client->get(
    '/index.rss' => sub {
        my ($self, $tx) = @_;

        is($tx->res->code, 200);
    }
)->process;

# Archive page
$client->get(
    '/archive' => sub {
        my ($self, $tx) = @_;

        is($tx->res->code, 200);
        like($tx->res->body, qr/Archive/);
    }
)->process;

# Tags page
$client->get(
    '/tags' => sub {
        my ($self, $tx) = @_;

        is($tx->res->code, 200);
        like($tx->res->body, qr/Tags/);
    }
)->process;
