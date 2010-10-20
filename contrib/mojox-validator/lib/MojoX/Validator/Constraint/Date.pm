package MojoX::Validator::Constraint::Date;

use strict;
use warnings;

use base 'MojoX::Validator::Constraint';

require Time::Local;

sub is_valid {
    my ($self, $value) = @_;

    my $re = $self->args->{split} || '/';
    my ($year, $month, $day) = split($re, $value);

    return 0 unless $year && $month && $day;

    eval { Time::Local::timegm(0, 0, 0, $day, $month - 1, $year); };

    return $@ ? 0 : 1;
}

1;
__END__

=head1 NAME

MojoX::Validator::Constraint::Date - Date constraint

=head1 SYNOPSIS

    $validator->field('date')->constraint('date');
    $validator->field('date')->constraint('date', split => '/');

=head1 DESCRIPTION

Checks whether a value is a valid date. Date is a string with a separator (C</>
by default), that is splitted into C<year, month, day> sequence and then
validated.

=head1 METHODS

=head2 C<is_valid>

Validates the constraint.

=head1 SEE ALSO

L<MojoX::Validator>, L<MojoX::Constraint>

=cut
