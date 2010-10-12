package Bootylicious::TagCloud;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('articles');

use Bootylicious::Iterator;

sub new {
    my $self = shift->SUPER::new(@_);

    return $self->build;
}

sub last_modified { shift->articles->last_modified }

sub build {
    my $self = shift;

    my $tags = {};
    while (my $article = $self->articles->next) {
        foreach my $tag (@{$article->tags}) {
            $tags->{$tag}->{count} ||= 0;
            $tags->{$tag}->{count}++;
        }
    }

    my @tags;
    foreach my $tag (sort keys %$tags) {
        push @tags, {name => $tag, count => $tags->{$tag}->{count}};
    }

    return Bootylicious::Iterator->new(elements => [@tags]);
}

1;
