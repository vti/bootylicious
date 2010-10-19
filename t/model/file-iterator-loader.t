#!/usr/bin/env perl

use strict;
use warnings;

use utf8;

use Test::More tests => 7;

use FindBin;

use_ok('Bootylicious::FileIteratorLoader');

my $files;
my $file;

$files = Bootylicious::FileIteratorLoader->new(
    element_class => 'Bootylicious::Document',
    root          => "$FindBin::Bin/unlikelytoexist"
)->load;
is $files->size => 0;

$files = Bootylicious::FileIteratorLoader->new(
    element_class => 'Bootylicious::Document',
    root          => "$FindBin::Bin/documents",
    filter        => qr/^[^\.]+\.[^\.]+$/
)->load;
is $files->size => 4;

$file = $files->next;
is $file->name => 'foo-bar-baz';

$file = $files->next;
is $file->name => 'привет';

$file = $files->next;
is $file->name => 'hello';

$file = $files->next;
is $file->name => 'last';
