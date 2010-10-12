package Bootylicious::ArticleIteratorFinder;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('iterator');

use Bootylicious::ArticleWithPager;
use Bootylicious::IteratorSearchable;

sub new {
    my $self = shift->SUPER::new(@_);

    Carp::croak q/Iterator is a required parameter/ unless $self->iterator;

    return $self;
}

sub find {
    my $self = shift;
    my ($year, $month, $name) = @_;

    my $iterator = Bootylicious::IteratorSearchable->new($self->iterator);

    return $iterator->find_first(
        sub {
            my ($iterator, $elem) = @_;

            return unless $elem->created->year == $year;
            return unless $elem->created->month == $month;
            return unless $elem->name eq $name;

            my $prev = $iterator->take_prev;
            my $next = $iterator->take_next;

            return Bootylicious::ArticleWithPager->new(
                $elem,
                prev => $prev,
                next => $next
            );
        }
    );
}

1;
