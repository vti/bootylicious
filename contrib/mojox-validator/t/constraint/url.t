#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;

use MojoX::Validator::Constraint::Url;

my $constraint = MojoX::Validator::Constraint::Url->new;

ok($constraint);

ok(!$constraint->is_valid('hello'));
ok(!$constraint->is_valid('http://foo'));

ok($constraint->is_valid('http://foo.com'));
