#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 19;

use MojoX::Validator::Condition;
use MojoX::Validator::Field;

my $condition = MojoX::Validator::Condition->new;
$condition->when('bar');

my $foo = MojoX::Validator::Field->new(name => 'foo');
my $bar = MojoX::Validator::Field->new(name => 'bar');

ok(!$condition->match({}));
ok(!$condition->match({bar => $bar}));
$bar->value('');
ok(!$condition->match({bar => $bar}));
$bar->value('foo');
ok($condition->match({bar => $bar}));

$condition = MojoX::Validator::Condition->new;
$condition->when([qw/foo bar/]);

ok(!$condition->match({}));
$foo->value('bar');
ok(!$condition->match({foo => $foo}));
$bar->value('foo');
ok(!$condition->match({bar => $bar}));
ok($condition->match({foo => $foo, bar => $bar}));
$foo->multiple(1)->value([qw/bar baz/]);
ok($condition->match({foo => $foo, bar => $bar}));

$condition = MojoX::Validator::Condition->new;
$condition->when('foo')->regexp(qr/^\d+$/)->length(1, 3);

ok(!$condition->match({}));
$foo->value('bar');
ok(!$condition->match({foo => $foo}));
$foo->value(1234);
ok(!$condition->match({foo => $foo}));
$foo->value(123);
ok($condition->match({foo => $foo}));

$condition = MojoX::Validator::Condition->new;
$condition->when('foo')->regexp(qr/^\d+$/)->length(1, 3);

$foo->error('Required');
ok(!$condition->match({foo => $foo}));
$foo->clear_error;

$condition = MojoX::Validator::Condition->new;
$condition->when('foo')->regexp(qr/^\d+$/)->length(1, 3)->when('bar')
  ->regexp(qr/^\d+$/);

ok(!$condition->match({}));
$foo->value('bar');
$bar->value('foo');
ok(!$condition->match({foo => $foo, bar => $bar}));
$foo->value('barr');
$bar->value('foo');
ok(!$condition->match({foo => $foo, bar => $bar}));
$foo->value(123);
$bar->value('foo');
ok(!$condition->match({foo => $foo, bar => $bar}));
$foo->value(123);
$bar->value(123);
ok($condition->match({foo => $foo, bar => $bar}));
