#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 4;

use FindBin;
use Bootylicious::Timestamp;

use_ok('Bootylicious::Pingback');

my $pingback;

$pingback = Bootylicious::Pingback->new(
    created    => Bootylicious::Timestamp->new(epoch => time),
    source_uri => 'http://example.com'
);
ok($pingback);

my $path = "$FindBin::Bin/pingback/20101010-foo.md.pingbacks";
unlink $path;
$pingback->create($path);
$pingback->create($path);
ok(-e $path);

my @lines = split "\n" => do { local $/; open my $fh, '<', $path or die $!; <$fh> };
is @lines => 2;

unlink $path;
