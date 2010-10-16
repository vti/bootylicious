package Bootylicious::Plugin::CanonicalUrl;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

sub register {
    my ($self, $app, $conf) = @_;

    main::under(\&_bridge);
}

sub _bridge {
    my $self = shift;

    my $path = $self->req->url->path->to_string;
    return 1 unless $path;

    return 1 if $path =~ m{/$};

    return 1 if $path =~ m{\.(?:[a-z]+)$};

    my $canonical_location =
      $self->req->url->clone->path($path . '.html')->to_abs;

    $self->app->log->debug("Path is not canonical: " . $self->req->url);
    $self->app->log->debug("Redirecting to: " . $canonical_location);

    $self->redirect_to($canonical_location);

    # Stop
    return 0;
}

1;
