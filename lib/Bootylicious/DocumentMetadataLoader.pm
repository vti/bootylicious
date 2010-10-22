package Bootylicious::DocumentMetadataLoader;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('path');

sub load {
    my $self = shift;

    my $path = $self->path;

    open my $fh, '<:encoding(UTF-8)', $path or return;

    my $metadata = {};
    while (my $line = <$fh>) {
        last unless $line;
        last unless $line =~ m/^(.*?): (.*)/;

        my $key   = lc $1;
        my $value = $2;

        $metadata->{$key} = $value;
    }

    return $metadata;
}

1;
