package MojoX::Validator::Constraint::Equal;

use strict;
use warnings;

use base 'MojoX::Validator::Constraint';

sub is_valid {
    my ($self, $values) = @_;

    my $e = shift @$values;

    foreach (@$values) {
        return 0
          unless (!defined $e && !defined $_)
          || (defined $e && defined $_ && $e eq $_);
    }

    return 1;
}

1;
__END__

=head1 NAME

MojoX::Validator::Constraint::Equal - Equal constraint

=head1 SYNOPSIS

    $validator->group('all_are_equal' => [qw/password confirm_password/])
      ->equal;

=head1 DESCRIPTION

Group constraint that validates that all values are the same.

=head1 METHODS

=head2 C<is_valid>

Validates the constraint.

=head1 SEE ALSO

L<MojoX::Validator>, L<MojoX::Constraint>

=cut
