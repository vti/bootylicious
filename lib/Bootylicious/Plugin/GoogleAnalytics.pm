package Bootylicious::Plugin::GoogleAnalytics;

use strict;
use warnings;

use base 'Mojo::Base';

use Mojo::ByteStream 'b';

sub register {
    my ($self, $app, $conf) = @_;

    $conf ||= {};

    return unless $conf->{urchin};

    $app->plugins->add_hook(
        after_dispatch => sub {
            my ($self, $c) = @_;

            return unless $c->res->code && $c->res->code == 200;

            my $body = $c->res->body;
            return unless $body;

            $c->stash(urchin => $conf->{urchin});

            my $ga_script = $c->render_partial(
                'template',
                format         => 'html',
                template_class => __PACKAGE__,
            );

            $ga_script = b($ga_script)->encode('UTF-8');

            $body =~ s{</body>}{$ga_script</body>};
            $c->res->body($body);
        }
    );
}

1;
__DATA__

@@ template.html.ep
<script type="text/javascript">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%= $urchin %>']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>
