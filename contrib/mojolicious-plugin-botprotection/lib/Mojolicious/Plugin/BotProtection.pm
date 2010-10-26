package Mojolicious::Plugin::BotProtection;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Mojo::ByteStream;

sub register {
    my ($self, $app, $conf) = @_;

    $conf ||= {};

    my $bot_detected_cb = $conf->{bot_detected_cb} || \&_bot_detected_cb;

    # Dummy input configuration
    my $dummy_input = $conf->{dummy_input} || 'dummy';

    $app->renderer->add_helper(
        dummy_input => sub {
            shift->helper('input_tag' => $dummy_input => value => '' => style =>
                  'display:none');
        }
    );

    $app->renderer->add_helper(
        signed_form_for => sub {
            my $c    = shift;
            my $name = shift;

            # Captures
            my $captures = ref $_[0] eq 'HASH' ? shift : {};

            my $url = $c->url_for($name, $captures);

            $c->session(
                form_signature => join(
                    ',' => "time=" . time,
                    "url=" . $url->to_abs
                )
            );

            my $cb = pop;
            $c->helper(
                'tag' => 'form' => action => $url,
                @_ => sub { $c->helper('dummy_input') . $cb->($c); }
            );
        }
    );

    $app->plugins->add_hook(
        after_static_dispatch => sub {
            my ($self, $c) = @_;

            return if $c->res->code;

            # Below are only checks for the forms
            return unless $c->req->method eq 'POST';

            # No GET params within POST are allowed
            return $bot_detected_cb->($c, 'POST with GET')
              if $c->req->url->query;

            # Bot filled out a dummy input
            return $bot_detected_cb->($c, 'Dummy input submitted')
              if $c->param($dummy_input);

            # No chance for the bot without cookies
            return $bot_detected_cb->($c, 'No cookies')
              unless $c->signed_cookie('mojolicious');

            # Identical fields
            return $bot_detected_cb->($c, 'Identical fields')
              if _identical_fields($c, $conf);

            # Wrong form signature
            return $bot_detected_cb->($c, 'Wrong form signature')
              if _wrong_signature($c, $conf);

            return;
        }
    );
}

sub _identical_fields {
    my $c    = shift;
    my $conf = shift;

    # Identical fields configuration
    my $max = $conf->{max_identical_fields} || 2;

    my @params = keys %{$c->req->params->to_hash};
    if (@params > $max) {
        my $values = {};

        for (@params) {
            my $value = $c->param($_);
            next unless defined $value;
            next unless $value ne '';

            ++$values->{$value};
        }

        my @repeated = sort { $b <=> $a } grep { $_ >= 2 } values %$values;
        return 1 if $repeated[0] && $repeated[0] > $max;
    }

    return;
}

sub _wrong_signature {
    my $c    = shift;
    my $conf = shift;

    my $signature = $c->session('form_signature');
    return 1 unless $signature;

    my @values = split /,/, $signature;
    my %params = map { split /=/ } @values;

    # Wrong form
    return 1 if $params{url} ne $c->req->url->to_abs;

    # Too far in the past
    return 1 if time - $params{time} > 60 * 60;    # Hour

    # Too fast
    return 1 if time - $params{time} < 1;

    return;
}

sub _bot_detected_cb {
    my $c      = shift;
    my $action = shift;

    my $ip     = $c->tx->remote_address;
    my $ua     = $c->req->headers->user_agent;
    my $method = $c->req->method;
    my $path   = $c->req->url->path;
    $c->app->log->debug(
        "Bot detected: $action: $method $path from $ip via $ua");

    return $c->render_text(
        'You look like a bot. If you are not, please contact webmaster',
        status => 400,
        layout => undef
    );
}

1;
