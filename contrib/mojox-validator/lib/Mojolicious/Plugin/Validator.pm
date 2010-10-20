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
