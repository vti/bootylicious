package MojoX::Validator::Constraint::Regexp;

use strict;
use warnings;

use base 'MojoX::Validator::Constraint';

sub is_valid {
    my ($self, $value) = @_;

    my $re = $self->args;

    return $value =~ m/$re/ ? 1 : 0;
}

1;
__END__

=head1 NAME

MojoX::Validator::Constraint::Regexp - Regexp constraint

=head1 SYNOPSIS

    $validator->field('number')->regexp(qr/^\d+$/);

=head1 DESCRIPTION

Checks if the value mathes provided regular expression. Don't forget C<^> and
C<$> symbols if you want to check the whole value.

=head1 METHODS

=head2 C<is_valid>

Validates the constraint.

=head1 SEE ALSO

L<MojoX::Validator>, L<MojoX::Constraint>

=cut
