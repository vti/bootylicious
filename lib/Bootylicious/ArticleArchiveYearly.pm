package Bootylicious::ArticleArchiveYearly;

use strict;
use warnings;

use base 'Bootylicious::ArticleArchiveBase';

use Bootylicious::DocumentIteratorWithDates;
use Bootylicious::Year;

sub build {
    my $self = shift;

    my $years = {};
    while (my $article = $self->articles->next) {
        my $year = $article->created->year;

        next if $self->year && $self->year != $year;

        $years->{$year} ||= [];
        push @{$years->{$year}}, $article;
    }

    my @years;
    foreach my $year (sort { $b <=> $a } keys %$years) {
        push @years,
          Bootylicious::Year->new(
            year     => $year,
            articles => Bootylicious::DocumentIteratorWithDates->new(
                elements => $years->{$year}
            )
          );
    }

    $self->articles(
        Bootylicious::DocumentIteratorWithDates->new(elements => [@years]));

    return $self;
}

sub is_yearly  {1}
sub is_monthly {0}

1;
