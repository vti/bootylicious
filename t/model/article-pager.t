#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 16;

use FindBin;
use Bootylicious::ArticleIteratorLoader;

use_ok('Bootylicious::ArticlePager');

my $pager;

$pager = Bootylicious::ArticlePager->new(
    limit    => 3,
    iterator => Bootylicious::Iterator->new(elements => [])
);
is $pager->articles->size => 0;
ok !$pager->prev_timestamp;
ok !$pager->next_timestamp;

$pager = Bootylicious::ArticlePager->new(
    limit => 3,
    iterator =>
      Bootylicious::ArticleIteratorLoader->new(root => "$FindBin::Bin/pager")
      ->load
);
is $pager->articles->size        => 3;
is $pager->articles->first->name => 'zab';
is $pager->articles->last->name  => 'oof';
ok !$pager->prev_timestamp;
is $pager->next_timestamp => '20100103T00:00:00';

$pager = Bootylicious::ArticlePager->new(
    timestamp => '20100103T00:00:00',
    limit     => 3,
    iterator =>
      Bootylicious::ArticleIteratorLoader->new(root => "$FindBin::Bin/pager")
      ->load
);
is $pager->articles->size           => 3;
is $pager->articles->first->name    => 'baz';
is $pager->articles->last->name     => 'foo';
is $pager->prev->created->timestamp => '20100106T00:00:00';
ok !$pager->next;

$pager =
  Bootylicious::ArticlePager->new(iterator =>
      Bootylicious::ArticleIteratorLoader->new(root => "$FindBin::Bin/pager")
      ->load);
is $pager->articles->size               => 6;
is $pager->articles->first->created->timestamp => '20100106T00:00:00';
