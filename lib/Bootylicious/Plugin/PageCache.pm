package Bootylicious::Plugin::PageCache;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use File::stat;
use File::Spec;

__PACKAGE__->attr('root');

sub register {
    my ($self, $app, $conf) = @_;

    $conf ||= {};
    $conf->{root} ||= 'cache';

    #->rel_dir('public/cache');

    $self->root($conf->{root});

    $app->plugins->add_hook(before_render => sub { _cache_hit(@_, $conf) });
    $app->plugins->add_hook(
        after_dispatch => sub { _cache_response(@_, $conf) });
}

sub _cache_path {
    my ($c, $root) = @_;

    my $path = $c->req->url->path;
    $path = 'index' if !$path || $path eq '/';
    $path =~ s{^/}{};

    $path =~ s{/}{-}g;

    $path .= '.html' unless $path =~ m/\.html$/;

    return File::Spec->catfile($root, $path);
}

sub _cache_file {
    my ($c, $path) = @_;

    return File::Spec->catfile($c->app->static->root, $path);
}

sub _cache_hit {
    my ($self, $c, $conf) = @_;

    return unless $c->req->method eq 'GET';

    return unless my $booty = $c->stash('booty');

    my $last_modified = $booty->modified->epoch;
    return unless $last_modified;

    my $path = _cache_path($c, $conf->{root});
    my $file = _cache_file($c, $path);
    return unless $file;

    if (-r $file && stat($file)->mtime >= $last_modified) {
        $c->app->log->debug('Serving cached version');
        return $c->render_static($path);
    }

    $c->stash(page_cache => 1);

    return;
}

sub _cache_response {
    my ($self, $c, $conf) = @_;

    return unless $c->req->method eq 'GET';

    return unless $c->res->code && $c->res->code eq 200;

    return unless $c->stash('page_cache');

    my $path = _cache_path($c, $conf->{root});
    my $file = _cache_file($c, $path);
    return unless $file;

    open my $fh, '>:encoding(UTF-8)', $file or return;
    print $fh $c->res->body;

    $c->app->log->debug('Cached response');
}

1;
