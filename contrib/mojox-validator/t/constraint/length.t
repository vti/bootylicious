#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 10;

use MojoX::Validator::Constraint::Length;

my $constraint =
  MojoX::Validator::Constraint::Length->new(args => [3, 5]);

ok($constraint);

is($constraint->is_valid('Hello'), 1);
is($constraint->is_valid('He'), 0);
is($constraint->is_valid('Hello!'), 0);

$constraint = MojoX::Validator::Constraint::Length->new(args => 1);

ok($constraint);

is($constraint->is_valid('Hello'), 0);
is($constraint->is_valid('a'), 1);

$constraint = MojoX::Validator::Constraint::Length->new(args => [1]);

ok($constraint);

is($constraint->is_valid('Hello'), 0);
is($constraint->is_valid('a'), 1);
