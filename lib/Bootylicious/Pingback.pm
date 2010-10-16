package Bootylicious::Pingback;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('created');
__PACKAGE__->attr('source_uri');

sub create {
    my $self = shift;
    my $path = shift;

    open my $file, '>>:encoding(UTF-8)', $path or return;

    print $file $self->created->timestamp . ' ' . $self->source_uri . "\n";
}

1;
