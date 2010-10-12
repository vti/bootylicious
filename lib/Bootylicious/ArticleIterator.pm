package Bootylicious::ArticleIterator;

use strict;
use warnings;

use base 'Bootylicious::DocumentIterator';

use Bootylicious::Article;

sub create_element { shift; Bootylicious::Article->new(@_) }

sub last_created  { shift->_max('created') }
sub last_modified { shift->_max('modified') }

sub _max {
    my $self = shift;
    my ($method) = @_;

    my $max = 0;

    $self->rewind;

    while (my $article = $self->next) {
        $max = $article->$method if $article->$method > $max;
    }

    $self->rewind;

    return $max;
}

1;
