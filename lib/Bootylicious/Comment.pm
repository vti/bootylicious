package Bootylicious::Comment;

use strict;
use warnings;

use base 'Mojo::Base';

use Bootylicious::Timestamp;
use File::stat;

__PACKAGE__->attr([qw/path created author email url content/]);

sub create {
    my $self = shift;
    my $path = shift;

    open my $file, '>:encoding(UTF-8)', $path or return;

    $self->path($path);

    print $file 'Author: ', $self->author || '', "\n";
    print $file 'Email: ',  $self->email  || '', "\n";
    print $file 'Url: ',    $self->url    || '', "\n";
    print $file "\n";
    print $file $self->content || '';
}

sub load {
    my $self = shift;
    my $path = shift;

    open my $fh, '<:encoding(UTF-8)', $path or return;

    $self->path($path);

    my $metadata = {};
    while (my $line = <$fh>) {
        last unless $line;
        last unless $line =~ m/^(.*?): (.*)/;

        my $key   = lc $1;
        my $value = $2;

        $metadata->{$key} = $value;
    }

    $self->created(Bootylicious::Timestamp->new(epoch => stat($path)->mtime));
    $self->author($metadata->{author} || '');
    $self->email($metadata->{email}   || '');
    $self->url($metadata->{url}       || '');

    my $content = '';
    while (my $line = <$fh>) {
        $content .= $line;
    }

    $self->content($content);

    return $self;
}

1;
