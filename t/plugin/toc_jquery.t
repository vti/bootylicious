#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;


use_ok( 'Bootylicious::Plugin::AjaxLibLoader' );
use_ok( 'Bootylicious::Plugin::TocJquery' );
diag( "Testing Bootylicious::Plugin::TocJquery $Bootylicious::Plugin::TocJquery::VERSION, Perl $], $^X" );

