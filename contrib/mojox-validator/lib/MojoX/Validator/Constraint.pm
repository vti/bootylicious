package MojoX::Validator::Constraint;

use strict;
use warnings;

use base 'Mojo::Base';

use Mojo::ByteStream;

__PACKAGE__->attr('args' => sub { [] });

sub is_valid {0}

sub error {
    my $self = shift;

    my $name = ref($self) ? ref($self) : $self;
    my $namespace = __PACKAGE__;
    $name =~ s/^$namespace\:://;

    return
      uc(Mojo::ByteStream->new($name)->decamelize->to_string)
      . '_CONSTRAINT_FAILED';
}

1;
__END__

=head1 NAME

MojoX::Validator::Constraint - Basic condition class

=head1 SYNOPSIS

    Used internally.

=head1 DESCRIPTION

Basic class for constraints. Subclass it to write new conditions.

=head1 ATTRIBUTES

=head2 C<args>

Holds args that are passed to the constraint.

=head2 C<error>

Holds constraint's error message.

=head1 METHODS

=head2 C<is_valid>

Checks whether constraint is valid.

=cut
