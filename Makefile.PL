#!/usr/bin/env perl

# Copyright (C) 2009, Viacheslav Tykhanovskyi

use 5.008001;

use strict;
use warnings;

use ExtUtils::MakeMaker;

my $mm = $ExtUtils::MakeMaker::VERSION;

WriteMakefile(
    NAME         => 'bootylicious',
    VERSION_FROM => 'bootylicious.pl',
    ABSTRACT     => 'Blog software',
    AUTHOR       => 'Viacheslav Tykhanovskyi <vti@cpan.org>',

    ($mm < 6.3002 ? () : ('LICENSE' => 'artistic_2')),

    (   $mm < 6.46
        ? ()
        : ( META_MERGE => {
                requires  => {perl => '5.008001'},
                resources => {
                    homepage => 'http://getbootylicious.org',
                    license  => 'http://dev.perl.org/licenses/',
                    repository =>
                      'http://github.com/vti/bootylicious/tree/master'
                },
                no_index => {directory => [qw/t/]}
            },
            META_ADD => {
                build_requires     => {},
                configure_requires => {}
            },
        )
    ),

    EXE_FILES => ['bootylicious.pl'],
    PM        => {},
    PREREQ_PM => {
        'File::Basename'    => 0,
        'Mojo'              => 0,
        'Pod::Simple::HTML' => 0,
        'Time::Local'       => 0,
        'Time::Piece'       => 0,
    },
    test => {TESTS => 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t'}
);

1;
