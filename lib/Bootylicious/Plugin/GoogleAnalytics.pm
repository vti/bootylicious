package Bootylicious::Plugin::GoogleAnalytics;

use strict;
use warnings;

use base 'Mojo::Base';
use Mojo::ByteStream 'b';

__PACKAGE__->attr('urchin');

sub hook_finalize {
    my $self = shift;
    my $c = shift;

    return unless $self->urchin;

    my $body = $c->res->body;

    $c->stash(urchin => $self->urchin);

    my $ga_script = $c->render_partial(
        'template',
        format         => 'html',
        template_class => __PACKAGE__,
        handler        => 'ep'
    );

    $ga_script = b($ga_script)->encode('utf-8');

    $body =~ s{</body>}{$ga_script</body>};
    $c->res->body($body);
}

1;
__DATA__

@@ template.html.ep
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("<%= $urchin %>");
pageTracker._trackPageview();
} catch(err) {}</script>
