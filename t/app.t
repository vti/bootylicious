#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 7;

use Mojo::Transaction::Single;
use Mojo::Client;

use FindBin;
require "$FindBin::Bin/../bootylicious.pl";

my $client = Mojo::Client->new;

# Index page
my $tx = Mojo::Transaction::Single->new_get('/');
$client->process_app(app(), $tx);
is($tx->res->code, 200);

$tx = Mojo::Transaction::Single->new_get('/index');
$client->process_app(app(), $tx);
is($tx->res->code, 200);

# Index rss page
$tx = Mojo::Transaction::Single->new_get('/index.rss');
$client->process_app(app(), $tx);
is($tx->res->code, 200);

# Archive page
$tx = Mojo::Transaction::Single->new_get('/archive');
$client->process_app(app(), $tx);
is($tx->res->code, 200);
like($tx->res->body, qr/Archive/);

# Tags page
$tx = Mojo::Transaction::Single->new_get('/tags');
$client->process_app(app(), $tx);
is($tx->res->code, 200);
like($tx->res->body, qr/Tags/);
