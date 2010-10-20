#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 10;

use MojoX::Validator::Constraint::Email;

my $constraint = MojoX::Validator::Constraint::Email->new;

ok($constraint);

ok(!$constraint->is_valid('hello'));
ok(!$constraint->is_valid('vti@'));
ok(!$constraint->is_valid('vti@cpan'));
ok(!$constraint->is_valid('vti@cpan.'));
ok(!$constraint->is_valid('vti@.cpan'));
ok(!$constraint->is_valid('v' x 65 . '@' . 'c' x 251 .'.com'));
ok(!$constraint->is_valid('v' x 64 . '@' . 'c' x 252 .'.com'));

ok($constraint->is_valid('vti@cpan.org'));
ok($constraint->is_valid('v' x 64 . '@' . 'c' x 251 .'.com'));
