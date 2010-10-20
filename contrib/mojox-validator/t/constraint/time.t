#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 9;

use MojoX::Validator::Constraint::Time;

my $constraint = MojoX::Validator::Constraint::Time->new(args => [split => ':']);

ok($constraint);

is($constraint->is_valid('Hello'), 0);
is($constraint->is_valid('33:33:00'), 0);
is($constraint->is_valid('00:60:01'), 0);
is($constraint->is_valid('25:00:01'), 0);

is($constraint->is_valid('00:59:00'), 1);
is($constraint->is_valid('00:00:01'), 1);
is($constraint->is_valid('12:12:59'), 1);
is($constraint->is_valid('23:00:03'), 1);
