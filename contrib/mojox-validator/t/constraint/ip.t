#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 13;

use MojoX::Validator::Constraint::Ip;

my $constraint = MojoX::Validator::Constraint::Ip->new;

ok($constraint);

ok(!$constraint->is_valid('hello'));
ok(!$constraint->is_valid('123.1111.23.12'));

ok($constraint->is_valid('88.12.3.1'));
ok($constraint->is_valid('127.0.0.1'));

ok($constraint->is_valid('10.0.1.2'));
ok($constraint->is_valid('172.18.1.2'));
ok($constraint->is_valid('192.168.2.1'));

ok($constraint->is_valid('255.0.0.255'));

$constraint = MojoX::Validator::Constraint::Ip->new(args => [noprivate => 1]);

ok(!$constraint->is_valid('127.0.0.1'));
ok(!$constraint->is_valid('10.0.1.2'));
ok(!$constraint->is_valid('172.18.1.2'));
ok(!$constraint->is_valid('192.168.2.1'));
