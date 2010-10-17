package Bootylicious::CommentIteratorLoader;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('glob');

use Bootylicious::Comment;
use Mojo::ByteStream;

sub load {
    my $self     = shift;
    my $iterator = shift;

    my @comments = ();

    my @files = glob $self->glob;
    foreach my $file (@files) {
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
