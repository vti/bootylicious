package MojoX::Validator::ConstraintBuilder;

use strict;
use warnings;

use base 'Mojo::Base';

use Mojo::Loader;
use Mojo::ByteStream;

sub build {
    my $self = shift;
    my $name = shift;

    my $class = "MojoX::Validator::Constraint::"
      . Mojo::ByteStream->new($name)->camelize;

    # Load class
    if (my $e = Mojo::Loader->load($class)) {
        die ref $e
          ? qq/Can't load class "$class": $e/
          : qq/Class "$class" doesn't exist./;
    }

    return $class->new(args => @_ > 1 ? [@_] : ($_[0] || []));
}

1;
__END__

=head1 NAME

MojoX::Validator::ConstraintBuilder - Constraint factory

=head1 SYNOPSIS

    $field->constraint(length => [1, 2]);

=head1 DESCRIPTION

A factory class for constraints. Build a new object.

=head1 METHODS

=head2 C<build>

    MojoX::Validator::ConstraintBuilder->build('length' => [1, 3]);

Build a new constraint object passing all additional parameters.

=cut
