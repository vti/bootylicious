package MojoX::Validator::Bulk;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr(fields => sub { [] });

sub each {
    my $self = shift;
    my $cb   = shift;

    foreach my $field (@{$self->fields}) {
        $cb->($field);
    }

    return $self;
}

1;
__END__

=head1 NAME

MojoX::Validator::Bulk - Internal object for multiple fields processing

=head1 SYNOPSIS

    $validator->field(qw/foo bar/)->each(sub { shift->required(1) });

=head1 DESCRIPTION

Bulk object. Holds multiple fields that were created by L<MojoX::Validator>.

=head1 METHODS

=head2 C<each>

    $bulk->each(sub { shift->required(1) });

Every field is passed to this callback as the first parameter.

=head1 SEE ALSO

L<MojoX::Validator>

=cut
