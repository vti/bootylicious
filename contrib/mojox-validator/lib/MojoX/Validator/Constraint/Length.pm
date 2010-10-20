package MojoX::Validator::Constraint::Length;

use strict;
use warnings;

use base 'MojoX::Validator::Constraint';

sub is_valid {
    my ($self, $value) = @_;

    my $len = length $value;

    my $args = $self->args;
    my ($min, $max) = ref $args eq 'ARRAY' ? @{$args} : ($args);

    return $len eq $min ? 1 : 0 unless $max;

    return $len >= $min && $len <= $max ? 1 : 0;
}

1;
__END__

=head1 NAME

MojoX::Validator::Constraint::Length - Length constraint

=head1 SYNOPSIS

    $validator->field('name')->length(10);
    $validator->field('name')->length(1, 40);

=head1 DESCRIPTION

Checks whether the value is exactly C<n> characters length, or is between
C<n, m> values.

=head1 METHODS

=head2 C<is_valid>

Validates the constraint.

=head1 SEE ALSO

L<MojoX::Validator>, L<MojoX::Constraint>

=cut
