#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 17;

use Test::Mojo;

use FindBin;
require "$FindBin::Bin/../bootylicious";

my $t = Test::Mojo->new;

# Index page
$t->get_ok('/')->status_is(200)->content_like(qr/booty/);
$t->get_ok('/index')->status_is(302);
$t->get_ok('/index.html')->status_is(200)->content_like(qr/booty/);

# Index rss page
$t->get_ok('/index.rss')->status_is(200)->content_like(qr/rss/);

# Archive page
$t->get_ok('/archive.html')->status_is(200)->content_like(qr/Archive/);

# Tags page
$t->get_ok('/tags.html')->status_is(200)->content_like(qr/Tags/);
