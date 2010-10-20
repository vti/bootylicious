package MojoX::Validator::Constraint::Callback;

use strict;
use warnings;

use base 'MojoX::Validator::Constraint';

sub is_valid {
    my ($self, $value) = @_;

    my $cb = $self->args;

    return $cb->($value);
}

1;
__END__

=head1 NAME

MojoX::Validator::Constraint::Callback - Callback constraint

=head1 SYNOPSIS

    $validator->field('foo')->callback(sub {
        my $value = shift;

        return 1 if $value =~ m/^\d+$/;

        return (0, 'Value is not a number');
    });

=head1 DESCRIPTION

Run a callback to validate a field. Return a true value when validation
succeded, and false value when failed.

In order to set your own error instead of a default one return an array where
the error message is the second argument.

=head1 METHODS

=head2 C<is_valid>

Validates the constraint.

=head1 SEE ALSO

L<MojoX::Validator>, L<MojoX::Constraint>

=cut
