package Bootylicious::TagCloud;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('articles');

use Bootylicious::Iterator;
use Bootylicious::Tag;

sub new {
    my $self = shift->SUPER::new(@_);

    return $self->build;
}

sub modified { shift->articles->modified }

sub build {
    my $self = shift;

    my $tags = {};
    while (my $article = $self->articles->next) {
        foreach my $name (@{$article->tags}) {
            my $tag = $tags->{$name};

            $tag->{count} ||= 0;
            $tag->{count}++;

            $tag->{created} = $article->created unless $tag->{created};
            $tag->{created} = $article->created
              if $article->created < $tag->{created};
            $tag->{modified} ||= 0;
            $tag->{modified} = $article->modified
              if $article->modified > $tag->{modified};

            $tags->{$name} = $tag;
        }
    }

    my @tags;
    foreach my $name (sort keys %$tags) {
        my $tag = $tags->{$name};

        push @tags,
          Bootylicious::Tag->new(
            name     => $name,
            count    => $tag->{count},
            created  => $tag->{created},
            modified => $tag->{modified}
          );
    }

    return Bootylicious::Iterator->new(elements => [@tags]);
}

1;
