package Bootylicious::PingbackIterator;

use strict;
use warnings;

use base 'Bootylicious::Iterator';

__PACKAGE__->attr('path');

use Bootylicious::Pingback;
use Bootylicious::Timestamp;

sub new {
    my $self = shift->SUPER::new(@_);

    return $self->load;
}

sub load {
    my $self = shift;

    open my $fh, '<:encoding(UTF-8)', $self->path or return $self;

    my @pingbacks;
    while (my $line = <$fh>) {
        chomp $line;

        my ($created, $source_uri) = split ' ' => $line;

        $created = Bootylicious::Timestamp->new(timestamp => $created);

        push @pingbacks,
          Bootylicious::Pingback->new(
            created    => $created,
            source_uri => $source_uri
          );
    }

    $self->elements([@pingbacks]);

    return $self;
}

1;
