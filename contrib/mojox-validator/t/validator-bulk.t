#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;

use MojoX::Validator;

my $validator = MojoX::Validator->new;

$validator->field([qw/foo bar baz/])->each(sub { shift->regexp(qr/^\d+$/) });

ok($validator->validate({foo => 1, bar => 2, baz => 3}));
ok(!$validator->validate({foo => 'a', bar => 2,   baz => 3}));
ok(!$validator->validate({foo => 'a', bar => 'b', baz => 3}));
ok(!$validator->validate({foo => 'a', bar => 'b', baz => 'c'}));
