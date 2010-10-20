#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 6;

use_ok('MojoX::Validator::Group');
use_ok('MojoX::Validator::Field');

my $foo = MojoX::Validator::Field->new(name => 'foo')->value(1);
my $bar = MojoX::Validator::Field->new(name => 'bar')->value(2);

my $group = MojoX::Validator::Group->new(name => 'group1', fields => [$foo, $bar]);
$group->unique;
ok($group->is_valid);
ok(!$group->error);

$bar->value(1);
$group = MojoX::Validator::Group->new(fields => [$foo, $bar]);
$group->unique;
ok(!$group->is_valid);
is($group->error, 'UNIQUE_CONSTRAINT_FAILED');
