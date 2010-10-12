package Bootylicious::Iterator;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('elements');

sub new {
    my $self = shift->SUPER::new(@_);

    $self->rewind;

    return $self;
}

sub rewind { shift->{index} = 0 }

sub size { scalar @{shift->{elements}} }

sub first { shift->{elements}->[0] }
sub last  { shift->{elements}->[-1] }

sub current {
    my $self = shift;

    my $index = $self->{index};
    $index-- if $index;

    return $self->{elements}->[$index];
}

sub take_next {
    my $self = shift;

    return unless $self->has_next;

    return $self->{elements}->[$self->{index}];
}

sub take_prev {
    my $self = shift;

    return if $self->{index} < 2;

    return $self->{elements}->[$self->{index} - 2];
}

sub has_next {
    my $self = shift;

    return $self->{index} < $self->size ? 1 : 0;
}

sub has_prev {
    my $self = shift;

    return $self->{index} > 0 ? 1 : 0;
}

sub next {
    my $self   = shift;
    my $length = shift;

    if (!$length) {
        return unless $self->has_next;

        return $self->{elements}->[$self->{index}++];
    }

    my $offset = $self->{index};

    if ($length + $offset > $self->size) {
        $length = $self->size - $offset;
    }

    my $sliced_elements =
      [@{$self->{elements}}[$offset .. $offset + $length - 1]];

    $self->{index} += @$sliced_elements;

    return $self->new(elements => $sliced_elements);
}

sub prev {
    my $self   = shift;
    my $length = shift;

    if (!$length) {
        return unless $self->has_prev;

        return $self->{elements}->[--$self->{index}];
    }

    return $self->new(elements => []) if $self->{index} == 0;

    $self->{index}--;

    my $offset = $self->{index} - $length;
    if ($offset < 0) {
        $offset = 0;
        $length = $self->{index};
    }

    my $sliced_elements =
      [@{$self->{elements}}[$offset .. $offset + $length - 1]];

    $self->{index} -= @$sliced_elements;

    return $self->new(elements => $sliced_elements);
}

1;
