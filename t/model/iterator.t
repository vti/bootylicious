#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 30;

use FindBin;

use_ok('Bootylicious::Iterator');

my $i;
my $page;
my $element;

$i = Bootylicious::Iterator->new(elements => []);
is $i->size => 0;
ok not defined $i->next;
ok not defined $i->prev;
ok not defined $i->first;
ok not defined $i->last;
ok not defined $i->next(10)->next;
ok not defined $i->next(10)->prev;
ok not defined $i->prev(10)->prev;
ok not defined $i->prev(10)->next;

$i = Bootylicious::Iterator->new(elements => [{name => 1}, {name => 2}, {name => 3}]);
is $i->size => 3;

$element = $i->next;
ok $element;
is $element->{name} => 1;

$element = $i->next;
ok $element;
is $element->{name} => 2;

$i->next;

ok not defined $i->next;

$i->rewind;

$page = $i->next(10);
is $page->size => 3;
ok not defined $i->next;

$page = $i->next(10);
is $page->size => 0;

$i->rewind;
$page = $i->prev(10);
is $page->size => 0;

$i->rewind;
is $i->next(10)->size => 3;
$page = $i->prev(10);
is $page->size => 2;
ok not defined $i->prev;

$i->rewind;
$page = $i->next(2);
is $page->size => 2;

$i->next;
$i->next;
ok not defined $i->next;
$page = $i->prev(3);
is $page->size => 2;
ok not defined $i->prev;

$i->rewind;
ok $i->current;
is $i->current->{name} => 1;
$i->next;
is $i->current->{name} => 1;
