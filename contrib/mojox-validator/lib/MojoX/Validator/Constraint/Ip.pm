package MojoX::Validator::Constraint::Ip;

use strict;
use warnings;

use base 'MojoX::Validator::Constraint';

sub is_valid {
    my ($self, $value) = @_;

    my %args = @{$self->args};

    my @octets = split /\./ => $value;
    return unless @octets == 4;

    for (@octets) {
        return unless m/^\d+$/ && $_ >= 0 && $_ <= 255;
    }

    if ($args{noprivate}) {
        return 0 if $octets[0] == 10;
        return 0 if $octets[0] == 127;
        return 0 if $octets[0] == 172 && ($octets[1] >= 16 && $octets[1] <= 31);
        return 0 if $octets[0] == 192 && $octets[1] == 168;
    }

    return 1;
}

1;
__END__

=head1 NAME

MojoX::Validator::Constraint::Ip - Ip constraint

=head1 SYNOPSIS

    $validator->field('ip')->constraint('ip');
    $validator->field('ip')->constraint('ip', noprivate => 1);

=head1 DESCRIPTION

Checks whether a value looks like an ip address.

=head1 ARGUMENTS

=head2 C<noprivate>

Private networks are considered invalid. Default is B<OFF>.

=head1 METHODS

=head2 C<is_valid>

Validates the constraint.

=head1 SEE ALSO

L<MojoX::Validator>, L<MojoX::Constraint>

=cut
