package MojoX::Validator::Constraint::Time;

use strict;
use warnings;

use base 'MojoX::Validator::Constraint';

sub is_valid {
    my ($self, $value) = @_;

    my %args = @{$self->args};
    my $re = $args{split} || ':';

    my ($h, $m, $s) = split($re, $value);
    return 0 unless defined $h && defined $m && defined $s;

    $h =~ m/^\d+$/ || return 0;
    $h >= 0 && $h <= 23 || return 0;

    $m =~ m/^\d+$/ || return 0;
    $m >= 0 && $m <= 59 || return 0;

    $s =~ m/^\d+$/ || return 0;
    $s >= 0 && $s <= 59 || return 0;

    return 1;
}

1;
__END__

=head1 NAME

MojoX::Validator::Constraint::Time - Time constraint

=head1 SYNOPSIS

    $validator->field('time')->constraint(time => [split => ':']);

=head1 DESCRIPTION

Checks whether a value is a valid time. Time is a string with a separator (C<:>
by default), that is splitted into C<hour, minute, second> sequence and then
validated.

=head1 METHODS

=head2 C<is_valid>

Validates the constraint.

=head1 SEE ALSO

L<MojoX::Validator>, L<MojoX::Constraint>

=cut
