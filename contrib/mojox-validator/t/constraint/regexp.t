#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;

use MojoX::Validator::Constraint::Regexp;

my $constraint =
  MojoX::Validator::Constraint::Regexp->new(args => qr/^[a-z]+$/);

ok($constraint);

is($constraint->is_valid('hello'), 1);

is($constraint->is_valid('09'), 0);

is($constraint->is_valid('H'), 0);
