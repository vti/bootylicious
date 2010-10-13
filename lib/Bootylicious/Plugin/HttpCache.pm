package Bootylicious::Plugin::HttpCache;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Mojo::Date;

sub register {
    my ($self, $app) = @_;

    $app->plugins->add_hook(
        before_render => \&_check_if_modified_since_header);
    $app->plugins->add_hook(after_dispatch => \&_set_last_modified_header);
}

sub _check_if_modified_since_header {
    my ($self, $c) = @_;

    return if $c->res->code;

    my $date = $c->req->headers->header('If-Modified-Since');
    return unless $date;

    $date = Mojo::Date->new($date)->epoch;

    my $last_modified = _last_modified($c);
    return unless $last_modified;

    if ($last_modified > $date) {
        $c->render_text('', status => 304, layout => undef);
    }
}

sub _set_last_modified_header {
    my ($self, $c) = @_;

    my $last_modified = _last_modified($c);
    return unless $last_modified;

    $c->res->headers->header(
        'Last-Modified' => Mojo::Date->new($last_modified));
}

sub _last_modified {
    my $self = shift;

    my $booty = $self->stash('booty');
    return unless $booty;

    return $booty->modified->epoch if ref $booty;

    return;
}

1;
