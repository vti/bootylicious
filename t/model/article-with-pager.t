#!/usr/bin/env perl

package Article;
use base 'Mojo::Base';

package main;

use strict;
use warnings;

use Test::More tests => 3;

use_ok('Bootylicious::ArticleWithPager');

my $article = Bootylicious::ArticleWithPager->new(Article->new);

ok $article->can('prev');
ok $article->can('next');
