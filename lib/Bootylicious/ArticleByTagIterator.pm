package Bootylicious::ArticleByTagIterator;

use strict;
use warnings;

use base 'Bootylicious::Decorator';

__PACKAGE__->attr('tag');

use Bootylicious::IteratorSearchable;

sub new {
    my $self = shift->SUPER::new(@_);

    return $self->build;
}

sub build {
    my $self = shift;

    my $tag = $self->tag;

    return Bootylicious::IteratorSearchable->new($self->object)->find_all(
        sub {
            my ($iterator, $elem) = @_;

            return unless scalar grep { $_ eq $tag } @{$elem->tags};

            return $elem;
        }
    );
}

1;
