#!/usr/bin/env perl

# Copyright (C) 2010, Viacheslav Tykhanovkyi

use 5.008007;

use strict;
use warnings;

use ExtUtils::MakeMaker;

my ($mm) = $ExtUtils::MakeMaker::VERSION =~ /^([^_]+)/;

WriteMakefile(
    NAME         => 'MojoX::Validator',
    VERSION_FROM => 'lib/MojoX/Validator.pm',
    ABSTRACT     => 'Data validator',
    AUTHOR       => 'Viacheslav Tykhanovskyi <vti@cpan.org>',

    ($mm < 6.3002 ? () : ('LICENSE' => 'artistic_2')),

    (   $mm < 6.46
        ? ()
        : ( META_MERGE => {
                requires  => {perl => '5.008007'},
                resources => {
                    license    => 'http://dev.perl.org/licenses/',
                    repository => 'http://github.com/vti/mojox-validator'
                },
                no_index => {directory => [qw/t/]}
            },
            META_ADD => {
                build_requires     => {},
                configure_requires => {}
            },
        )
    ),

    PREREQ_PM => {'Mojolicious' => '0.999931'},
    test      => {TESTS         => 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t'}
);
