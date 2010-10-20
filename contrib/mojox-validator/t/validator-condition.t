#!/usr/bin/env perl

use strict;
use warnings;

use MojoX::Validator;

use Test::More tests => 6;

my $validator = MojoX::Validator->new;
$validator->field([qw/foo bar/])->each(sub { shift->length(1, 3) });

$validator->when('bar')->regexp(qr/^\d+$/)
  ->then(sub { shift->field('foo')->required(1) });

ok($validator->validate({}));
ok(!$validator->validate({foo => 'barr'}));
ok($validator->validate({foo => 'bar'}));
ok($validator->validate({bar => 'foo'}));
ok($validator->validate({foo => 'bar', bar => 'foo'}));
ok(!$validator->validate({bar => 123}));
