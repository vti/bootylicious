#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 22;

BEGIN { require FindBin; $ENV{BOOTYLICIOUS_HOME} = "$FindBin::Bin/../"; }

use Bootylicious;

my $app = Bootylicious::app;
$app->log->level('error');

my $articlesdir = "$FindBin::Bin/articles";
mkdir $articlesdir;
unlink $_ for glob("$articlesdir/*");

Bootylicious::config(articlesdir => $articlesdir);

my ($articles, $pager) = Bootylicious::get_articles();
is(@$articles, 0);
is_deeply($pager, {});

my $c = 1;
for (qw/ one two three four five six seven eight nine ten/) {
    _write_article("200909" . sprintf("%02d", $c) . "T10:10:10-$_.pod",
        "Title: $_\n\n$_");

    $c++
}

($articles, $pager) = Bootylicious::get_articles();
is(@$articles, 10);
is_deeply($pager, {});

($articles, $pager) = Bootylicious::get_articles(limit => 3);
is(@$articles, 3);
is ($articles->[0]->{title}, 'ten');
is ($articles->[1]->{title}, 'nine');
is ($articles->[2]->{title}, 'eight');
is_deeply($pager, {next => '20090907T10:10:10'});

($articles, $pager) = Bootylicious::get_articles(limit => 3, timestamp => '20090907T10:10:10');
is(@$articles, 3);
is ($articles->[0]->{title}, 'seven');
is ($articles->[1]->{title}, 'six');
is ($articles->[2]->{title}, 'five');
is_deeply($pager, {prev => '20090910T10:10:10', next => '20090904T10:10:10'});

($articles, $pager) = Bootylicious::get_articles(limit => 3, timestamp => '20090904T10:10:10');
is(@$articles, 3);
is ($articles->[0]->{title}, 'four');
is ($articles->[1]->{title}, 'three');
is ($articles->[2]->{title}, 'two');
is_deeply($pager, {prev => '20090907T10:10:10', next => '20090901T10:10:10'});

($articles, $pager) = Bootylicious::get_articles(limit => 3, timestamp => '20090901T10:10:10');
is(@$articles, 1);
is ($articles->[0]->{title}, 'one');
is_deeply($pager, {prev => '20090904T10:10:10'});

unlink $_ for glob("$articlesdir/*");
rmdir $articlesdir;

sub _write_article {
    my ($path, $content) = @_;

    open FILE, "> $articlesdir/$path";
    print FILE $content;
    close FILE;
}
