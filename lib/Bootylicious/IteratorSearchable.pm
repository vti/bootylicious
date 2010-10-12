package Bootylicious::IteratorSearchable;

use strict;
use warnings;

use base 'Bootylicious::Decorator';

sub find_first {
    my $self = shift;
    my $cb   = shift;

    while (my $el = $self->object->next) {
        if (my $res = $cb->($self->object, $el)) {
            return $res;
        }
    }

    return;
}

1;
