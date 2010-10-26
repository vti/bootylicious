package Bootylicious::Plugin::Admin;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

require Carp;

sub register {
    my ($self, $app, $conf) = @_;

    $conf ||= {};

    Carp::croak qq/Password and username are required for this plugin to work/
      unless $conf->{username} && $conf->{password};

    $app->routes->route('/admin')->detour(class => 'Bootylicious::Admin', conf => $conf);
}

1;
