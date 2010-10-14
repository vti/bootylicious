package Bootylicious::DocumentContentLoader;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('path');

sub load {
    my $self = shift;

    my $path = $self->path;

    open my $fh, '<:encoding(UTF-8)', $path or return {};
    while (my $line = <$fh>) {
        last if $line eq '';
        last if $line !~ m/^(.*?): /;
    }

    my $content = '';
    while (my $line = <$fh>) {
        $content .= $line;
    }

    return {content => $content};
}

1;
