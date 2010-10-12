package Bootylicious::ArticleIterator;

use strict;
use warnings;

use base 'Bootylicious::DocumentIterator';

use Bootylicious::Article;
use Bootylicious::Timestamp;

sub create_element { shift; Bootylicious::Article->new(@_) }

sub last_created  { shift->_max('created') }
sub last_modified { shift->_max('modified') }

sub _max {
    my $self = shift;
    my ($method) = @_;

    my $max = 0;

    $self->rewind;

    while (my $article = $self->next) {
        $max = $article->$method->epoch if $article->$method->epoch > $max;
    }

    $self->rewind;

    return Bootylicious::Timestamp->new(epoch => $max);
}

1;
