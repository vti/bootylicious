#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 9;

use MojoX::Validator::Constraint::Subset;

my $constraint =
  MojoX::Validator::Constraint::Subset->new(args => [1, 5, 7]);

ok($constraint);

is($constraint->is_valid(1), 1);
is($constraint->is_valid(7), 1);
is($constraint->is_valid(2), 0);

is($constraint->is_valid([1]), 1);
is($constraint->is_valid([1, 7]), 1);
is($constraint->is_valid([1, 5, 7]), 1);
is($constraint->is_valid([1, 3, 7]), 0);
is($constraint->is_valid([2]), 0);
