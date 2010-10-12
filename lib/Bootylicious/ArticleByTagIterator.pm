package Bootylicious::ArticleByTagIterator;

use strict;
use warnings;

use base 'Bootylicious::Decorator';

__PACKAGE__->attr('tag');

use Bootylicious::ArticleIterator;

sub new {
    my $self = shift->SUPER::new(@_);

    return $self->build;
}

sub build {
    my $self = shift;

    my $tag = $self->tag;

    my @articles;
    while (my $article = $self->object->next) {
        if (scalar grep { $_ eq $tag } @{$article->tags}) {
            push @articles, $article;
        }
    }

    return Bootylicious::ArticleIterator->new(elements => [@articles]);
}

1;
