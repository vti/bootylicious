package Bootylicious::DocumentStatLoader;

use strict;
use warnings;

use base 'Mojo::Base';

use Bootylicious::Timestamp;

require Carp;
use File::stat;

my $TIMESTAMP_RE = qr/(\d\d\d\d)(\d?\d)(\d?\d)(?:T(\d\d):?(\d\d):?(\d\d))?/;

__PACKAGE__->attr('path');

sub load {
    my $self = shift;
    my $path = $self->path;

    Carp::croak qq/Can't load: $!/ unless $path && -e $path;

    my ($name, $format) = ($path =~ m/\/([^\/]+)\.([^.]+)$/);

    Carp::croak qq/Bad file $path/ unless $name && $format;

    my $filename = join '.' => $name, $format;

    my $created;
    if ($name =~ s/^($TIMESTAMP_RE)-//) {
        $created = Bootylicious::Timestamp->new(timestamp => $1)->epoch;
        return unless defined $created;
    }

    my $modified = stat($path)->mtime;
    $created ||= $modified;

    return {
        name     => $name,
        filename => $filename,
        format   => $format,
        created  => Bootylicious::Timestamp->new(epoch => $created),
        modified => Bootylicious::Timestamp->new(epoch => $modified)
    };
}

1;
