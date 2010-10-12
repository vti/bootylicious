package Bootylicious::ArticleArchive;

use strict;
use warnings;

use base 'Mojo::Base';

use Bootylicious::Iterator;

__PACKAGE__->attr('articles');

sub new {
    my $self = shift->SUPER::new(@_);

    return $self->build;
}

sub build {
    my $self = shift;

    my $years = {};
    while (my $article = $self->articles->next) {
        my $year = $article->created->year;

        $years->{$year} ||= [];
        push @{$years->{$year}}, $article;
    }

    my @years;
    foreach my $year (sort { $b <=> $a } keys %$years) {
        push @years,
          { year     => $year,
            articles => Bootylicious::Iterator->new(elements => $years->{$year})
          };
    }

    return Bootylicious::Iterator->new(elements => [@years]);
}

1;
