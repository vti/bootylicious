package Bootylicious::ArticleArchiveMonthly;

use strict;
use warnings;

use base 'Bootylicious::ArticleArchiveBase';

use Bootylicious::IteratorWithDates;

__PACKAGE__->attr('month');

sub build {
    my $self = shift;

    my @articles;
    while (my $article = $self->articles->next) {
        my $year  = $article->created->year;
        my $month = $article->created->month;

        next if $self->year  && $self->year != $year;
        next if $self->month && $self->month != $month;

        push @articles, $article;
    }

    $self->articles(
        Bootylicious::IteratorWithDates->new(elements => [@articles]));

    return $self;
}

sub is_monthly {1}
sub is_yearly  {0}

1;
