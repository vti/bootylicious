package MojoX::Validator::Constraint::Url;

use strict;
use warnings;

use base 'MojoX::Validator::Constraint';

use constant NAME_MAX_LENGTH   => 64;
use constant DOMAIN_MAX_LENGTH => 255;

use Mojo::URL;

sub is_valid {
    my ($self, $value) = @_;

    my $url = Mojo::URL->new($value);

    return unless $url->scheme && $url->host;

    return unless $url->host =~ m/\./;

    return 1;
}

1;
