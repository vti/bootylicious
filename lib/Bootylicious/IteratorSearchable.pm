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

sub find_all {
    my $self = shift;
    my $cb = shift;

    $self->rewind;

    my @found_elements;
    while (my $el = $self->next) {
        if (my $res = $cb->($self->object, $el)) {
            push @found_elements, $res;
        }
    }

    return Bootylicious::Iterator->new(elements => [@found_elements]);
}

1;
