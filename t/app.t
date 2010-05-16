#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 29;
use Test::Mojo;

BEGIN { require FindBin; $ENV{BOOTYLICIOUS_HOME} = "$FindBin::Bin/../"; }

require "$FindBin::Bin/../bootylicious";

my $app = app();
$app->log->level('error');

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

# 404
$t->get_ok('/foo.html')->status_is(404)
  ->content_like(qr/The page you are looking for was not found/);

# 404 Articles
$t->get_ok('/articles/foo.html')->status_is(404)
  ->content_like(qr/The page you are looking for was not found/);

# 404 Drafts
$t->get_ok('/drafts/foo.html')->status_is(404)
  ->content_like(qr/The page you are looking for was not found/);

# 404 Pages
$t->get_ok('/pages/foo.html')->status_is(404)
  ->content_like(qr/The page you are looking for was not found/);
