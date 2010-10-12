package Bootylicious::Decorator;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('object');

sub new {
    my $class  = shift;
    my $object = shift;

    my $self = $class->SUPER::new(@_);

    $self->object($object);

    return $self;
}

our $AUTOLOAD;

sub AUTOLOAD {
    my $self = shift;

    my $method = $AUTOLOAD;

    return if $method =~ /^[A-Z]+?$/;
    return if $method =~ /^_/;
    return if $method =~ /(?:\:*?)DESTROY$/;

    $method = (split '::' => $method)[-1];

    return $self->object->$method(@_);
}

1;
