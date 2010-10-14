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
          Bootylicious::Year->new(
            year => $year,
            articles =>
              Bootylicious::IteratorWithDates->new(elements => $years->{$year})
          );
    }

    return Bootylicious::IteratorWithDates->new(elements => [@years]);
}

package Bootylicious::Year;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('year');
__PACKAGE__->attr('articles');

sub modified { shift->articles->modified }

1;
