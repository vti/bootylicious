package MojoX::Validator::Constraint::Email;

use strict;
use warnings;

use base 'MojoX::Validator::Constraint';

use constant NAME_MAX_LENGTH   => 64;
use constant DOMAIN_MAX_LENGTH => 255;

sub is_valid {
    my ($self, $value) = @_;

    return unless length $value <= NAME_MAX_LENGTH + 1 + DOMAIN_MAX_LENGTH;

    my ($name, $domain) = split /@/ => $value;
    return 0 unless defined $name && defined $domain;
    return 0 if $name eq '' || $domain eq '';

    return unless length $name <= NAME_MAX_LENGTH;
    return unless length $domain <= DOMAIN_MAX_LENGTH;

    my ($subdomain, $root) = split /\./ => $domain;
    return unless $subdomain && $root;

    return 1;
}

1;
__END__

=head1 NAME

MojoX::Validator::Constraint::Email - Email constraint

=head1 SYNOPSIS

    $validator->field('email')->email;

=head1 DESCRIPTION

Checks whether a value looks like an email address. This is a very simple yet
correct validation. It checks if an email has a correct length (name and domain) and
has at least one dot in the domain.

=head1 METHODS

=head2 C<is_valid>

Validates the constraint.

=head1 SEE ALSO

L<MojoX::Validator>, L<MojoX::Constraint>

=cut
