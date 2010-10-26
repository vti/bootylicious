package MojoX::Validator::Constraint::Url;

use strict;
use warnings;

use base 'MojoX::Validator::Constraint';

use Mojo::URL;

sub is_valid {
    my ($self, $value) = @_;

    my $url = Mojo::URL->new($value);

    return unless $url->scheme && $url->host;

    return unless $url->host =~ m/\./;

    return 1;
}

1;
__END__

=head1 NAME

MojoX::Validator::Constraint::Url - Url constraint

=head1 SYNOPSIS

    $validator->field('url')->url;

=head1 DESCRIPTION

Checks whether a value looks like an url address.

=head1 METHODS

=head2 C<is_valid>

Validates the constraint.

=head1 SEE ALSO

L<MojoX::Validator>, L<MojoX::Constraint>.

=cut
