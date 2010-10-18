package Bootylicious::CommentIteratorLoader;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('root');
__PACKAGE__->attr('path');

use Bootylicious::Comment;
use Mojo::ByteStream;

sub files {
    my $self = shift;

    my $root = $self->root;
    my $path = $self->path;

    return $path ? glob "$path.comment-*" : glob "$root/*.comment-*";
}

sub load {
    my $self     = shift;
    my $iterator = shift;

    my @comments = ();
    foreach my $file ($self->files) {
        my $comment;

        $file = Mojo::ByteStream->new($file)->decode('UTF-8');

        next unless $file =~ m/-(\d+)$/;

        $comment = Bootylicious::Comment->new;
        $comment->load($file);

        push @comments, $comment;
    }

    $iterator->elements(
        [sort { $a->created->epoch <=> $b->created->epoch } @comments]);
    $iterator->rewind;

    return $iterator;
}

1;
