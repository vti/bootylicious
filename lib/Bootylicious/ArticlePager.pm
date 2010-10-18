package Bootylicious::ArticlePager;

use strict;
use warnings;

use base 'Mojo::Base';

use Bootylicious::Timestamp;

__PACKAGE__->attr('timestamp');
__PACKAGE__->attr(limit => 10);
__PACKAGE__->attr('iterator');

sub prev {
    my $self = shift;

    my $i = $self->iterator;

    my $first = $self->articles->first;

    $i->rewind;
    while (my $article = $i->next) {
        if ($article->created->epoch == $first->created->epoch) {
            return $i->prev($self->limit)->last;
        }
    }

    return;
}

sub prev_timestamp {
    my $self = shift;

    my $prev = $self->prev;
    return '' unless $prev;

    return $prev->created->timestamp;
}

sub next {
    my $self = shift;

    my $i = $self->iterator;

    my $last = $self->articles->last;

    $i->rewind;
    while (my $article = $i->next) {
        last if $article->created->epoch == $last->created->epoch;
    }

    return $i->next;
}

sub next_timestamp {
    my $self = shift;

    my $next = $self->next;
    return '' unless $next;

    return $next->created->timestamp;
}

sub articles {
    my $self = shift;

    return $self->{articles} if $self->{articles};

    my $i = $self->iterator;

    if ($self->timestamp) {
        while (my $article = $i->next) {
            last
              if $article->created->epoch
                  <= Bootylicious::Timestamp->new(timestamp => $self->timestamp)->epoch;
        }
    }

    $i->prev;

    return $self->{articles} = $i->next($self->limit);
}

1;
