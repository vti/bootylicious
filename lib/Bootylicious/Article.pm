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

sub title { my $self = shift; $self->metadata(title => @_) || $self->name }
sub description { shift->metadata(description => @_) }
sub link        { shift->metadata(link        => @_) }

sub tags {
    my $self = shift;
    my $value = shift;

    if (defined $value) {
        $value = join ', ' => sort keys %{
            {   map { $_ => 1 }
                map { s/^\s+//; s/\s+$//; $_ }
                grep { $_ ne '' } split ',' => $value
            }
          } if $value ne '';
        return $self->metadata(tags => $value);
    }

    my $tags = $self->metadata('tags');

    return [map { s/^\s+//; s/\s+$//; $_ } split ',' => $tags];
}

sub has_tags { shift->tags ? 1 : 0 }

sub comments_enabled {
    my $self = shift;

    my $comments = $self->metadata('comments');

    return defined $comments && $comments =~ /^(no|false|disable)$/i ? 0 : 1;
}

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

    return Bootylicious::CommentIteratorLoader->new(path => $self->path)
      ->load(Bootylicious::Iterator->new);
}

sub comment {
    my $self = shift;
    my %params = @_;

    my $number = 1;

    if (my $last = $self->comments->last) {
        ($number) = ($last->path =~ m/\.comment-(\d+)/);
        $number++;
    }

    my $path = $self->path . '.comment-' . $number;

    my $comment = Bootylicious::Comment->new(@_);

    return $comment->create($path);
}

1;
