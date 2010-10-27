#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 49;

BEGIN { require FindBin; $ENV{MOJO_HOME} = "$FindBin::Bin/" }

use lib "$FindBin::Bin/../contrib/mojolicious-plugin-botprotection/lib";
use lib "$FindBin::Bin/../contrib/mojox-validator/lib";
use lib "$FindBin::Bin/../contrib/mojo/lib";

require "$FindBin::Bin/../bootylicious";

use Test::Mojo;

my $app = app();

$app->log->level('debug');

my $t = Test::Mojo->new;

# Index page
$t->get_ok('/')->status_is(200)->content_like(qr/booty/);

$t->get_ok('/index.html')->status_is(200)->content_like(qr/booty/);

# Index rss page
$t->get_ok('/index.rss')->status_is(200)->content_like(qr/rss/);

# Archive page
$t->get_ok('/articles.html')->status_is(200)->content_like(qr/Archive/);
$t->get_ok('/articles/2010.html')->status_is(200)->content_like(qr/Archive/);
$t->get_ok('/articles/2010/10.html')->status_is(200)
  ->content_like(qr/Archive/);

# Tags page
$t->get_ok('/tags.html')->status_is(200)->content_like(qr/Tags/);
$t->get_ok('/tags/foo.html')->status_is(200)->content_like(qr/foo/);

# Article Pages
$t->get_ok('/articles/2010/10/foo.html')->status_is(200);

# Page
$t->get_ok('/pages/about.html')->status_is(200)
  ->content_like(qr/About me/);

# Draft
#$t->get_ok('/draft/2010/10/draft.html')->status_is(200)
  #->content_like(qr/Draft/);

# 404
$t->get_ok('/foo.html')->status_is(404)
  ->content_like(qr/The page you are looking for was not found/);

# 404 Articles
$t->get_ok('/articles/foo/foo/foo.html')->status_is(404)
  ->content_like(qr/The page you are looking for was not found/);

# 404 Drafts
$t->get_ok('/drafts')->status_is(404)
  ->content_like(qr/The page you are looking for was not found/);

# 404 Drafts
$t->get_ok('/drafts/foo.html')->status_is(404)
  ->content_like(qr/The page you are looking for was not found/);

# 404 Pages
$t->get_ok('/pages/foo.html')->status_is(404)
  ->content_like(qr/The page you are looking for was not found/);

# 404 Pages
$t->get_ok('/../../etc/passwd')->status_is(404)
  ->content_like(qr/The page you are looking for was not found/);

# 404 Pages
$t->get_ok("/articles/2010/10/e,cho.html")->status_is(404);

undef $ENV{MOJO_HOME};
