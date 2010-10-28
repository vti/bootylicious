package Bootylicious::Plugin::HttpCache;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Mojo::ByteStream;

sub register {
    my ($self, $app) = @_;

    $app->plugins->add_hook(
        after_dispatch => sub {
            my ($self, $c) = @_;

            return unless $c->req->method eq 'GET';

            my $body = $c->res->body;
            return unless defined $body;

            my $our_etag = Mojo::ByteStream->new($body)->md5_sum;
            $c->res->headers->header('ETag' => $our_etag);

            my $browser_etag = $c->req->headers->header('If-None-Match');
            return unless $browser_etag && $browser_etag eq $our_etag;

            $c->res->code(304);
            $c->res->body('');
        }
    );
}

1;
