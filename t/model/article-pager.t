#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 13;

use FindBin;
use Bootylicious::ArticleIterator;

use_ok('Bootylicious::ArticlePager');

my $pager;

$pager = Bootylicious::ArticlePager->new(
    limit => 3,
    iterator =>
      Bootylicious::ArticleIterator->new(root => "$FindBin::Bin/pager")
);
is $pager->articles->size        => 3;
is $pager->articles->first->name => 'zab';
is $pager->articles->last->name  => 'oof';
ok not defined $pager->prev_timestamp;
is $pager->next_timestamp => '20100103T00:00:00';

$pager = Bootylicious::ArticlePager->new(
    timestamp => '20100103T00:00:00',
    limit     => 3,
    iterator =>
      Bootylicious::ArticleIterator->new(root => "$FindBin::Bin/pager")
);
is $pager->articles->size        => 3;
is $pager->articles->first->name => 'baz';
is $pager->articles->last->name  => 'foo';
is $pager->prev_timestamp        => '20100106T00:00:00';
ok not defined $pager->next_timestamp;

$pager =
  Bootylicious::ArticlePager->new(iterator =>
      Bootylicious::ArticleIterator->new(root => "$FindBin::Bin/pager"));
is $pager->articles->size                    => 6;
is $pager->articles->last_created->timestamp => '20100106T00:00:00';
