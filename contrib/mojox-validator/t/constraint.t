#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 2;

use MojoX::Validator::Constraint;

my $constraint = MojoX::Validator::Constraint->new;

ok($constraint);

is($constraint->is_valid(), 0);
