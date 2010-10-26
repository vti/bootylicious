package MojoX::Validator;

use strict;
use warnings;

use base 'Mojo::Base';

our $VERSION = '0.0007';

use MojoX::Validator::Bulk;
use MojoX::Validator::Condition;
use MojoX::Validator::Field;
use MojoX::Validator::Group;

require Carp;

__PACKAGE__->attr('bulk');
__PACKAGE__->attr(conditions => sub { [] });
__PACKAGE__->attr(fields     => sub { {} });
__PACKAGE__->attr(groups     => sub { [] });
__PACKAGE__->attr(has_errors => 0);
__PACKAGE__->attr(messages   => sub { {} });
__PACKAGE__->attr(trim       => 1);

sub field {
    my $self = shift;

    # Return field if it is already created
    return $self->{fields}->{$_[0]}
      if @_ == 1 && ref($_[0]) ne 'ARRAY' && $self->{fields}->{$_[0]};

    # Accept array or arrayref
    my @names = @_ == 1 && ref($_[0]) eq 'ARRAY' ? @{$_[0]} : @_;

    my $fields = [];
    foreach my $name (@names) {
        my $field = MojoX::Validator::Field->new(
            name     => $name,
            messages => $self->messages
        );

        $self->fields->{$name} = $field;
        push @$fields, $field;
    }

    return $self->fields->{$names[0]} if @names == 1;

    return MojoX::Validator::Bulk->new(fields => $fields);
}

sub when {
    my $self = shift;

    my $cond = MojoX::Validator::Condition->new->when(@_);

    push @{$self->conditions}, $cond;

    return $cond;
}

sub group {
    my $self   = shift;
    my $name   = shift;
    my $fields = shift;

    if (my ($exists) = grep { $_->name eq $name } @{$self->groups}) {
        Carp::croak "Fields of group '$name' already defined." if $fields;
        return $exists;
    }

    $fields = [map { $self->fields->{$_} } @$fields];

    my $group =
      MojoX::Validator::Group->new(name => $name, fields => $fields);
    push @{$self->groups}, $group;

    return $group;
}

sub errors {
    my ($self) = @_;

    my $errors = {};

    # Field errors
    foreach my $field (values %{$self->fields}) {
        $errors->{$field->name} = $field->error if $field->error;
    }

    # Group errors
    foreach my $group (@{$self->groups}) {
        $errors->{$group->name} = $group->error if $group->error;
    }

    return $errors;
}

sub clear_errors {
    my ($self) = @_;

    # Clear field errors
    foreach my $field (values %{$self->fields}) {
        $field->error('');
    }

    # Clear group errors
    foreach my $group (@{$self->groups}) {
        $group->error('');
    }

    $self->has_errors(0);
}

sub validate {
    my ($self) = shift;
    my $params = shift;

    $self->clear_errors;

    $self->_populate_fields($params);

    while (1) {
        $self->_validate_fields;
        $self->_validate_groups;

        my @conditions =
          grep { !$_->matched && $_->match($self->fields) }
          @{$self->conditions};
        last unless @conditions;

        foreach my $cond (@conditions) {
            $cond->then->($self);
        }
    }

    return $self->has_errors ? 0 : 1;
}

sub _populate_fields {
    my $self   = shift;
    my $params = shift;

    foreach my $field (values %{$self->fields}) {
        $field->clear_value;

        $field->value($params->{$field->name});
    }
}

sub _validate_fields {
    my $self   = shift;
    my $params = shift;

    foreach my $field (values %{$self->fields}) {
        $self->has_errors(1) unless $field->is_valid;
    }
}

sub _validate_groups {
    my $self = shift;

    foreach my $group (@{$self->groups}) {
        $self->has_errors(1) unless $group->is_valid;
    }
}

sub values {
    my $self = shift;

    my $values = {};

    foreach my $field (values %{$self->fields}) {
        $values->{$field->name} = $field->value
          if defined $field->value && !$field->error;
    }

    return $values;
}

1;
__END__

=head1 NAME

MojoX::Validator - Validator for Mojolicious

=head1 SYNOPSIS

    my $validator = MojoX::Validator->new;

    # Fields
    $validator->field('phone')->required(1)->regexp(qr/^\d+$/);
    $validator->field([qw/firstname lastname/])
      ->each(sub { shift->required(1)->length(3, 20) });

    # Groups
    $validator->field([qw/password confirm_password/])
      ->each(sub { shift->required(1) });
    $validator->group('passwords' => [qw/password confirm_password/])->equal;

    # Conditions
    $validator->field('document');
    $validator->field('number');
    $validator->when('document')->regexp(qr/^1$/)
      ->then(sub { shift->field('number')->required(1) });

    $validator->validate($values_hashref);
    my $errors_hashref = $validator->errors;
    my $pass_error = $validator->group('passwords')->error;
    my $validated_values_hashref = $validator->values;

=head1 DESCRIPTION

Data validator. Validates only the data. B<NO> form generation, B<NO> javascript
generation, B<NO> other stuff that does something else. Only data validation!

=head1 FEATURES

=over 4

    Validates data that is presented as a hash reference

    Multiple values

    Field registration

    Group validation

    Conditional validation

=back

=head1 CONVENTIONS

=over 4

    A value is considered empty when its value is B<NOT> C<undef>, C<''> or
    contains only spaces

    If a value is not required and during validation is empty there is B<NO>
    error

    If a value is passed as an array reference and an appropriate field is
    not multiple, than only the first value is taken, otherwise every value of
    the array reference is checked.

=back

=head1 ATTRIBUTES

=head2 C<messages>

    my $validator =
      MojoX::Validator->new(
        messages => {REQUIRED => 'This field is required'});

Replace default messages.

=head2 C<trim>

Trim field values. B<ON> by default.

=head1 METHODS

=head2 C<new>

    my $validator = MojoX::Validator->new;

Created a new L<MojoX::Validator> object.

=head2 C<clear_errors>

    $validator->clear_errors;

Clears errors.

=head2 C<field>

    $validator->field('foo');               # MojoX::Validator::Field object is returned
    $validator->field('foo');               # Already created field object is returned

    $validator->field(qw/foo bar baz/);     # MojoX::Validator::Bulk object is returned
    $validator->field([qw/foo bar baz/]);   # MojoX::Validator::Bulk object is returned

When a single value is passed creates L<MojoX::Validator::Field> object or
returns an already created field object.

When an array or an array reference is passed returns L<MojoX::Validator::Bulk> object. You can
call C<each> method to apply setting to multiple fields.

    $validator->field(qw/foo bar baz/)->each(sub { shift->required(1) });

=head2 C<group>

    $validator->field(qw/foo bar/)->each(sub { shift->required(1) });
    $validator->group('all_or_none' => [qw/foo bar/])->equal;

Registers a group constraint that will be called on group of fields. If group
validation fails the C<errors> hashref will have the B<group> name with an
appropriate error message, B<NOT> fields' names.

=head2 C<when>

    $validator->field('document');
    $validator->field('number');
    $validator->when('document')->regexp(qr/^1$/)
      ->then(sub { shift->field('number')->required(1) });

Registers a condition that is called when some conditions are met. You can do
whatever you want in condition's callback. Validation will be remade.

=head2 C<validate>

    $validator->validate({a => 'b'});
    $validator->validate({a => ['b', 'c']});
    $validator->validate({a => ['b', 'c'], b => 'd'});

Accepts and validated a hash reference that represents data that is being
validated. Hash values can be either a C<SCALAR> value or an C<ARRAREF> value,
which means that a field has multiple values. In case of an array reference, it
is checked if a field can have multiple values. Otherwise only the first value
is accepted and returned when C<values> method is called.

=head2 C<errors>

    $validator->errors; # {a => 'Required'}

Returns a hash reference of errors.

=head2 C<values>

    $validator->values;

Returns a hash reference of validated values. Only registered fields are returned,
that means that if some other values were passed to the C<validate> method they
are ignored.

=head1 DEVELOPMENT

=head2 Repository

    http://github.com/vti/mojox-validator

=head1 AUTHOR

Viacheslav Tykhanovskyi, C<vti@cpan.org>.

=head1 CREDITS

In alphabetical order:

Alex Voronov

Anatoliy Lapitskiy

Yaroslav Korshak

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010, Viacheslav Tykhanovskyi.

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
