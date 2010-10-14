package Bootylicious::IteratorWithDates;

use strict;
use warnings;

use base 'Bootylicious::DocumentIterator';

use Bootylicious::Timestamp;

sub created  { shift->_max('created') }
sub modified { shift->_max('modified') }

sub _max {
    my $self = shift;
    my ($method) = @_;

    return unless $self->size;

    my $max = 0;

    $self->rewind;

    while (my $elem = $self->next) {
        $max = $elem->$method->epoch if $elem->$method->epoch > $max;
    }

    $self->rewind;

    return Bootylicious::Timestamp->new(epoch => $max);
}

1;
