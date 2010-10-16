package Bootylicious::Plugin::HttpCache;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Mojo::ByteStream;

sub register {
    my ($self, $app) = @_;

    $app->plugins->add_hook(after_dispatch => \&_set_etag_header);
}

sub _set_etag_header {
    my ($self, $c) = @_;

    return unless $c->req->method eq 'GET';

    my $body = $c->res->body;

    my $our_etag = _calculate_etag($body);
    $c->res->headers->header('ETag' => $our_etag);

    my $browser_etag = $c->req->headers->header('If-None-Match');
    return unless $browser_etag && $browser_etag eq $our_etag;

    $c->res->code(304);
    $c->res->body('');
}

sub _calculate_etag { Mojo::ByteStream->new(shift)->md5_sum }

1;
