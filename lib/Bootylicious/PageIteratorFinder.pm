package Bootylicious::PageIteratorFinder;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('iterator');

use Bootylicious::IteratorSearchable;

sub new {
    my $self = shift->SUPER::new(@_);

    Carp::croak q/Iterator is a required parameter/ unless $self->iterator;

    return $self;
}

sub find {
    my $self = shift;
    my ($name) = @_;

    my $iterator = Bootylicious::IteratorSearchable->new($self->iterator);

    return $iterator->find_first(
        sub {
            my ($iterator, $elem) = @_;

            return unless $elem->name eq $name;

            return $elem;
        }
    );
}

1;
