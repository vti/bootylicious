#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;


use_ok( 'Bootylicious::Plugin::Gallery' );
use_ok("Image::Magick");
use_ok("Image::Magick::Thumbnail::Fixed");
diag( "Testing Bootylicious::Plugin::Gallery $Bootylicious::Plugin::Gallery::VERSION, Perl $], $^X" );


