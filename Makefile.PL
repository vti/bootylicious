# Copyright (C) 2009-2010, Viacheslav Tykhanovskyi

use 5.008001;

use strict;
use warnings;

use ExtUtils::MakeMaker;

my $mm = $ExtUtils::MakeMaker::VERSION;

WriteMakefile(
    NAME         => 'Bootylicious',
    VERSION_FROM => 'bootylicious',
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

    EXE_FILES => ['bootylicious'],
    PREREQ_PM => {
        'Carp'                               => 0,
        'File::Basename'                     => 0,
        'File::stat'                         => 0,
        'FindBin'                            => 0,
        'Mojolicious'                        => 0.999931,
        'MojoX::Validator'                   => 0,
        'Mojolicious::Plugin::BotProtection' => 0,
        'Time::Local'                        => 0,
        'Time::Piece'                        => 0,
    },
    test => {TESTS => 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t'}
);

1;
