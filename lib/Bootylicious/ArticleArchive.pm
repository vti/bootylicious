package Bootylicious::ArticleArchive;

use strict;
use warnings;

use base 'Mojo::Base';

use Bootylicious::Iterator;
use Bootylicious::Year;

__PACKAGE__->attr('articles');
__PACKAGE__->attr('year');
__PACKAGE__->attr('month');

sub new {
    my $self = shift->SUPER::new(@_);

    return $self->build;
}

sub build {
    my $self = shift;

    my $years = {};
    while (my $article = $self->articles->next) {
        my $year  = $article->created->year;
        my $month = $article->created->month;

        next if $self->year  && $self->year != $year;
        next if $self->month && $self->month != $month;

        $years->{$year} ||= [];
        push @{$years->{$year}}, $article;
    }

    my @years;
    foreach my $year (sort { $b <=> $a } keys %$years) {
        push @years,
          Bootylicious::Year->new(
            year     => $year,
            articles => Bootylicious::IteratorWithDates->new(
                elements => $years->{$year}
            )
          );
    }

    return Bootylicious::IteratorWithDates->new(elements => [@years]);
}

1;
