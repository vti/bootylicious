package Bootylicious::Article;

use strict;
use warnings;

use base 'Bootylicious::Document';

use Bootylicious::Timestamp;
use Bootylicious::Pingback;
use Bootylicious::PingbackIterator;
use Bootylicious::PingbackIteratorFinder;
use Bootylicious::Comment;
use Bootylicious::CommentIteratorLoader;

sub pingbacks {
    my $self = shift;

    return Bootylicious::PingbackIterator->new(
        path => $self->path . '.pingbacks');
}

sub has_pingback {
    my $self       = shift;
    my $source_uri = shift;

    my $finder =
      Bootylicious::PingbackIteratorFinder->new(iterator => $self->pingbacks);

    return $finder->find($source_uri) ? 1 : 0;
}

sub pingback {
    my $self       = shift;
    my $source_uri = shift;

    my $pingback = Bootylicious::Pingback->new(
        created    => Bootylicious::Timestamp->new(epoch => time),
        source_uri => $source_uri
    );
    return $pingback->create($self->path . '.pingbacks');
}

sub comments {
    my $self = shift;

    my $path = $self->path;

    return Bootylicious::CommentIteratorLoader->new(
        glob => "$path.comment-*")->load(Bootylicious::Iterator->new);
}

sub comment {
    my $self = shift;

    my $number = $self->comments->size + 1;

    my $path = $self->path . '.comment-' . $number;

    return Bootylicious::Comment->new(@_)->create($path);
}

1;
