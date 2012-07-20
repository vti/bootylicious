package Bootylicious::Plugin::Pingback;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Mojo::DOM;

sub register {
    my ($self, $app, $conf) = @_;

    $conf ||= {};

    $app->routes->route('/pingback')->to(cb => \&_pingback)->name('pingback');

    $app->plugins->on(
        after_dispatch => sub {
            my ($c) = @_;

            return unless $c->req->method =~ m/GET|HEAD/;

            return unless $c->res->code && $c->res->code == 200;

            return unless $c->match->endpoint->name eq 'article';

            $c->res->headers->header(
                'X-Pingback' => $c->url_for('pingback', format => undef)->to_abs);
        }
    );
}

sub _pingback {
    my $self = shift;

    my ($source_uri, $target_uri) = _parse_xmlrpc($self);
    return _render_bad_request($self) unless $source_uri && $target_uri;

    return _render_target_invalid($self)
      unless $target_uri =~ m{^/articles/(\d+)/(\d+)/(.*)};

    my ($year, $month, $name) = ($1, $2, $3);
    $name =~ s/\..*$//;

    my $article = $self->get_article($year, $month, $name);
    return _render_target_not_found($self) unless $article;

    $self->app->log->debug("Fetching $source_uri...");

    $self->client->get(
        $source_uri => sub {
            my $client = shift;

            $self->app->log->debug("Fetched $source_uri");

            return _render_source_not_found($self)
              unless $client->tx->res->code && $client->tx->res->code == 200;

            return _render_source_invalid($self)
              unless $client->tx->res->body =~ m{\Q$target_uri\E};

            return _render_pingback_already_registered($self)
              if $article->has_pingback($source_uri);

            $article->pingback($source_uri);

            return _render_success($self);
        }
    )->start;
}

sub _parse_xmlrpc {
    my $self = shift;

    return unless $self->req->method eq 'POST' && $self->req->body;

    my $dom = Mojo::DOM->new;
    $dom = $dom->parse($self->req->body);

    my $method = $dom->at('methodcall');
    return unless $method;

    my $method_name = $method->at('methodname');
    return unless $method_name->text eq 'pingback.ping';

    my ($source_uri, $target_uri) =
      $method->find('params > param > value > string')->each;
    return unless $source_uri && $target_uri;

    $source_uri = $source_uri->text;
    $target_uri = $target_uri->text;

    my $url = $self->url_for('/')->to_abs;
    return unless $target_uri =~ s/^\Q$url\E//;

    $target_uri = "/$target_uri" unless $target_uri =~ m{^/};

    return ($source_uri, $target_uri);
}

sub _render_success {
    my $self    = shift;
    my $message = shift;

    $message ||= 'Success';

    $self->render(
        'success',
        message        => $message,
        template_class => __PACKAGE__,
        layout         => undef
    );
}

sub _render_bad_request { _render_error(shift, 0 => 'Bad request') }

sub _render_target_not_found {
    _render_error(shift, 32 => 'The specified target URI does not exist.');
}

sub _render_target_invalid {
    _render_error(shift,
        33 => 'The specified target URI cannot be used as a target.');
}

sub _render_source_not_found {
    _render_error(shift, 16 => 'The source URI does not exist.');
}

sub _render_source_invalid {
    _render_error(shift,
        17 =>
          'The source URI does not contain a link to the target URI, and so cannot be used as a source.'
    );
}

sub _render_pingback_already_registered {
    _render_error(shift, 48 => 'The pingback has already been registered.');
}

sub _render_error {
    my $self = shift;
    my ($code, $message) = @_;

    $self->res->code(400) unless $code;

    $self->render(
        'fault',
        code           => $code,
        message        => $message,
        template_class => __PACKAGE__,
        layout         => undef
    );
}

1;
__DATA__

@@ success.html.ep
<?xml version="1.0"?>
<methodResponse>
    <params>
        <param>
            <value><string><%= $message %></string></value>
        </param>
    </params>
</methodResponse>

@@ fault.html.ep
<?xml version="1.0"?>
<methodResponse>
    <fault>
        <value>
            <struct>
                <member>
                    <name>faultCode</name>
                    <value><int><%= $code %></int></value>
                </member>
                <member>
                    <name>faultString</name>
                    <value><string><%= $message %></string></value>
                </member>
            </struct>
        </value>
    </fault>
</methodResponse>
