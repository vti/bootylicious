package Bootylicious::ArticleArchiveMonthly;

use strict;
use warnings;

use base 'Bootylicious::ArticleArchiveBase';

use Bootylicious::IteratorSearchable;

__PACKAGE__->attr('month');
__PACKAGE__->attr('iterator');

sub build {
    my $self = shift;

    my $iterator = Bootylicious::IteratorSearchable->new($self->articles)->find_all(
        sub {
            my ($iterator, $article) = @_;

            my $year  = $article->created->year;
            my $month = $article->created->month;

            return if $self->year  && $self->year != $year;
            return if $self->month && $self->month != $month;

            return $article;
        }
    );

    $self->articles($iterator);

    return $self;
}

sub is_monthly {1}
sub is_yearly  {0}

1;
