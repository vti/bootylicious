package Bootylicious::IteratorSearchable;

use strict;
use warnings;

use base 'Bootylicious::Decorator';

sub find_first {
    my $self = shift;
    my $cb   = shift;

    $self->rewind;

    while (my $el = $self->next) {
        if (my $res = $cb->($self->object, $el)) {
            return $res;
        }
    }

    return;
}

1;
