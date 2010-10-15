package Bootylicious::ArticleArchiveSimple;

use strict;
use warnings;

use base 'Mojo::Base';

use Bootylicious::Iterator;
use Bootylicious::Year;

__PACKAGE__->attr('articles');

sub new {
    my $self = shift->SUPER::new(@_);

    return $self->build;
}

sub build {
    my $self = shift;

    my @archive = ();
    while (my $article = $self->articles->next) {
        my $year  = $article->created->year;
        my $month = $article->created->month;

        push @archive, [$year, $month]
          if !@archive
              || ($archive[-1]->[0] != $year || $archive[-1]->[1] != $month);
    }

    return [@archive];
}

1;
