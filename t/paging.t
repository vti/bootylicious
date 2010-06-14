#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 18;
use Test::Mojo;

BEGIN { require FindBin; $ENV{BOOTYLICIOUS_HOME} = "$FindBin::Bin/../"; }

require "$FindBin::Bin/../bootylicious";

my $app = app();
$app->log->level('error');

my $articlesdir = "$FindBin::Bin/articles";
mkdir $articlesdir;
unlink $_ for glob("$articlesdir/*");

config(articlesdir => $articlesdir);

my $t = Test::Mojo->new;

$t->get_ok('/')->status_is(200)->content_like(qr/Nothing here yet/);

my $c = 1;
for (qw/one two three four five six seven eight nine ten/) {
    _write_article("200909" . sprintf("%02d", $c) . "T10:10:10-$_.pod",
        "Title: $_\n\n$_");

    $c++
}

$t->get_ok('/')->status_is(200)
  ->content_like(
    qr/.*ten.*nine.*eight.*seven.*six.*five.*four.*three.*two.*one.*/s);

config(pagelimit => 3);

$t->get_ok('/')->status_is(200)
  ->content_like(qr/.*ten.*nine.*eight.*20090907T10:10:10/s);

$t->get_ok('/index/20090907T10:10:10.html')->status_is(200)
  ->content_like(qr/.*seven.*six.*five.*20090910T10:10:10.*20090904T10:10:10/s);

$t->get_ok('/index/20090904T10:10:10.html')->status_is(200)
  ->content_like(qr/.*four.*three.*two.*20090907T10:10:10.*20090901T10:10:10/s);

$t->get_ok('/index/20090901T10:10:10.html')->status_is(200)
  ->content_like(qr/.*one.*20090904T10:10:10/s);

unlink $_ for glob("$articlesdir/*");
rmdir $articlesdir;

sub _write_article {
    my ($path, $content) = @_;

    open FILE, "> $articlesdir/$path";
    print FILE $content;
    close FILE;
}
