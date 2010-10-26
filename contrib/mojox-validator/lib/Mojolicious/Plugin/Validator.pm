package Mojolicious::Plugin::Validator;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use MojoX::Validator;

sub register {
    my ($self, $app, $conf) = @_;

    $conf ||= {};
    $conf->{messages} ||= {};

    $app->helper(create_validator =>
          sub { MojoX::Validator->new(messages => $conf->{messages}) });

    $app->helper(
        validate => sub {
            my $self      = shift;
            my $validator = shift;
            my $params    = shift;

            $params ||= $self->req->params->to_hash;

            return 1 if $validator->validate($params);

            $self->stash(validator_errors => $validator->errors);

            return;
        }
    );

    $app->helper(
        validator_error => sub {
            my $self = shift;
            my $name = shift;

            return unless my $errors = $self->stash('validator_errors');

            return unless my $message = $errors->{$name};

            return $self->tag('div' => class => 'error' => sub {$message});
        }
    );
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::Validator - Plugin for MojoX::Validator

=head1 SYNOPSIS

    # Mojolicious
    $self->plugin('validator');

    # Mojolicious::Lite
    plugin 'validator' => {
        messages => {
            REQUIRED                 => 'This field is required',
            LENGTH_CONSTRAINT_FAILED => 'Too big'
        }
    };

    sub action {
        my $self = shift;

        my $validator = $self->create_validator;
        $validator->field('username')->required(1)->length(3, 20);

        return unless $validator->validate;

        # Create a user for example
        ...
    }

    1;
    __DATA__

    @@ user.html.ep
    %= form_for 'user' => begin
        <%= label 'username' => begin %>Username<% end %>
        <%= input 'username' %>
        <%= validator_error 'username' %>

        <%= submit_button %>
    % end

=head1 DESCRIPTION

L<Mojolicious::Plugin::Validator> is a plugin for L<MojoX::Validator> that
simplifies parameters validation.

=head2 Options

=over

=item messages

    # Mojolicious::Lite
    plugin 'validator' => {
        messages => {
            REQUIRED                 => 'This field is required',
            LENGTH_CONSTRAINT_FAILED => 'Too big'
        }
    };

Replace default errors.

=back

=head2 Helpers

=over

    <%= validator_error 'username' %>

Render the appropriate error.

=back

=head1 METHODS

L<Mojolicious::Plugin::Validator> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 C<register>

    $plugin->register;

Register helpers in L<Mojolicious> application.

=head1 SEE ALSO

L<MojoX::Validator>, L<Mojolicious>.

=cut
