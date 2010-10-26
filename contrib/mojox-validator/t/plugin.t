#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

plan skip_all => 'working sockets required for this test!'
  unless Mojo::IOLoop->new->generate_port;
plan tests => 9;

use Mojolicious::Lite;

app->log->level('fatal');

plugin 'validator';

post '/' => sub { 
    my $self = shift;

    my $validator = $self->create_validator;

    $validator->field('foo')->required(1)->length(3, 10);

    if ($self->validate($validator)) {
        $self->render('ok');
    }
} => 'form';

use Test::Mojo;

my $t = Test::Mojo->new;

$t->post_form_ok('/' => {})->status_is(200)->content_like(qr/required/i);

$t->post_form_ok('/' => {foo => '12345678901'})->status_is(200)->content_like(qr/length/i);

$t->post_form_ok('/' => {foo => '123'})->status_is(200)->content_like(qr/ok/i);

__DATA__

@@ form.html.ep
%= form_for 'form', method => 'post' => begin
    <%= input_tag 'foo' %>
    <%= validator_error 'foo' %>
%= end

@@ ok.html.ep
OK
