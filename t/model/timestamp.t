#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 11;

use Bootylicious::Timestamp;

my $t = Bootylicious::Timestamp->new(epoch => 0);
is $t->timestamp              => '19700101T00:00:00';
is $t->epoch                  => 0;
is $t->year                   => 1970;
is $t->month                  => 1;
like $t->strftime('%a, %d %b %Y') => qr/^(Thu|Do), 01 Jan 1970$/;

$t = Bootylicious::Timestamp->new(timestamp => '19700101');
is $t->epoch     => 0;
is $t->timestamp => '19700101T00:00:00';

$t = Bootylicious::Timestamp->new(timestamp => '19700101T00:00:00');
is $t->epoch     => 0;
is $t->timestamp => '19700101T00:00:00';

ok $t->is_timestamp('19700101T00:00:00');
ok !$t->is_timestamp('197001a1T00:00:00');
