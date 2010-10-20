#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 46;

use_ok('MojoX::Validator::Field');

my $field = MojoX::Validator::Field->new(name => 'foo');
$field->required(1);
$field->length([3, 20]);
$field->regexp(qr/^\d+$/);

ok(!$field->is_valid);
is($field->error, 'REQUIRED');

$field->value('');
ok(!$field->is_valid);
is($field->error, 'REQUIRED');

$field->value('   ');
ok(!$field->is_valid);
is($field->error, 'REQUIRED');

$field->value('ab');
ok(!$field->is_valid);
is($field->error, 'LENGTH_CONSTRAINT_FAILED');

$field->value('abc');
ok(!$field->is_valid);
is($field->error, 'REGEXP_CONSTRAINT_FAILED');

$field->value(123);
ok($field->is_valid);
ok(!$field->error);

$field = MojoX::Validator::Field->new(name => 'foo');
$field->length([3, 20]);

ok($field->is_valid);
ok(!$field->error);

$field->value('ab');
ok(!$field->is_valid);
is($field->error, 'LENGTH_CONSTRAINT_FAILED');

$field->value('abc');
ok($field->is_valid);
ok(!$field->error);

$field = MojoX::Validator::Field->new(name => 'foo');
$field->length([3, 20]);

$field->value([qw/fo bar/]);
is($field->value, 'fo');
ok(!$field->is_valid);
is($field->error, 'LENGTH_CONSTRAINT_FAILED');

$field->value([qw/foo ba/]);
is($field->value, 'foo');
ok($field->is_valid);
ok(!$field->error);

$field->multiple(1);
$field->value([qw/foo ba/]);
is_deeply($field->value, [qw/foo ba/]);
ok(!$field->is_valid);

$field->value([qw/foo bar/]);
is_deeply($field->value, [qw/foo bar/]);
ok($field->is_valid);

$field = MojoX::Validator::Field->new(name => 'foo');
$field->required(1)->in(0, 1);
ok(!$field->is_defined);
ok($field->is_empty);
ok(!$field->is_valid);

$field->value(0);
ok($field->is_defined);
ok(!$field->is_empty);
ok($field->is_valid);

$field = MojoX::Validator::Field->new(name => 'foo');
$field->multiple(2, 3);
$field->value([qw/foo/]);
ok(!$field->is_valid);
is($field->error, 'NOT_ENOUGH');

$field->value([qw/foo bar/]);
ok($field->is_valid);

$field->value([qw/foo bar baz/]);
ok($field->is_valid);

$field->value([qw/foo bar baz urgh/]);
ok(!$field->is_valid);
is($field->error, 'TOO_MUCH');

$field = MojoX::Validator::Field->new(name => 'foo');
$field->multiple(2);
$field->value([qw/foo/]);
ok(!$field->is_valid);
is($field->error, 'NOT_ENOUGH');

$field->value([qw/foo bar/]);
ok($field->is_valid);

$field->value([qw/foo bar baz/]);
ok(!$field->is_valid);
is($field->error, 'TOO_MUCH');
