#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

plan skip_all => 'working sockets required for this test!'
  unless Mojo::IOLoop->new->generate_port;
plan tests => 36;

BEGIN {
    use FindBin;
    $ENV{MOJO_HOME} = "$FindBin::Bin/../";
}

use lib "$FindBin::Bin/../../contrib/mojo/lib";
use lib "$FindBin::Bin/../../contrib/mojox-validator/lib";
use lib "$FindBin::Bin/../../contrib/mojolicious-plugin-botprotection/lib";

use Mojolicious::Lite;

app->log->level('fatal');

push @{app->plugins->namespaces}, 'Bootylicious::Plugin';

app->helper(config => sub { {articles_directory => 'articles'} });

plugin 'booty_helpers';
plugin 'model';
plugin 'pingback';

get '/source_uri_invalid' => sub { shift->render_text('foo') } => 'foo';

get '/source_uri' => sub {
    my $self = shift;

    $self->render_text('http://localhost:/articles/2010/10/foo.html');
} => 'source';

get '/articles/:year/:month/:name' => sub {
    my $self = shift;

    $self->render_text('foo');
} => 'article';

use Test::Mojo;

my $t = Test::Mojo->new;

my $port = $t->client->test_server;

$t->get_ok('/pingback')->status_is(400)->content_like(qr/Bad request/);

$t->post_ok('/pingback' => '123')->status_is(400)
  ->content_like(qr/Bad request/);

$t->post_ok(
    '/pingback' => <<'EOF')->status_is(400)->content_like(qr/Bad request/);
<?xml version="1.0"?>
<methodCall>
    <methodName>foo.bar</methodName>
    <params>
        <param><value><string>foo</string></value></param>
    </params>
</methodCall>
EOF

$t->post_ok(
    '/pingback' => <<'EOF')->status_is(400)->content_like(qr/Bad request/);
<?xml version="1.0"?>
<methodCall>
    <methodName>pingback.ping</methodName>
    <params>
        <param><value><string>foo</string></value></param>
    </params>
</methodCall>
EOF

$t->post_ok(
    '/pingback' => <<'EOF')->status_is(400)->content_like(qr/Bad request/);
<?xml version="1.0"?>
<methodCall>
    <methodName>pingback.ping</methodName>
    <params>
        <param><value><string>http://foo</string></value></param>
        <param><value><string>http://bar</string></value></param>
    </params>
</methodCall>
EOF

$t->post_ok('/pingback' =>
      <<"EOF")->status_is(200)->content_like(qr/The specified target URI cannot be used as a target./);
<?xml version="1.0"?>
<methodCall>
    <methodName>pingback.ping</methodName>
    <params>
        <param><value><string>http://foo</string></value></param>
        <param><value><string>http://localhost:$port/</string></value></param>
    </params>
</methodCall>
EOF

$t->post_ok('/pingback' =>
      <<"EOF")->status_is(200)->content_like(qr/The specified target URI does not exist./);
<?xml version="1.0"?>
<methodCall>
    <methodName>pingback.ping</methodName>
    <params>
        <param><value><string>http://foo</string></value></param>
        <param><value><string>http://localhost:$port/articles/2009/12/foo</string></value></param>
    </params>
</methodCall>
EOF

#$t->post_ok('/pingback' =>
#<<"EOF")->status_is(200)->content_like(qr/The source URI does not exist./);
#<?xml version="1.0"?>
#<methodCall>
#<methodName>pingback.ping</methodName>
#<params>
#<param><value><string>http://whathtefuckisgoingonhere123321.com</string></value></param>
#<param><value><string>http://localhost:$port/articles/2010/10/foo</string></value></param>
#</params>
#</methodCall>
#EOF

$t->post_ok('/pingback' =>
      <<"EOF")->status_is(200)->content_like(qr/The source URI does not exist./);
<?xml version="1.0"?>
<methodCall>
    <methodName>pingback.ping</methodName>
    <params>
        <param><value><string>/not_found</string></value></param>
        <param><value><string>http://localhost:$port/articles/2010/10/foo</string></value></param>
    </params>
</methodCall>
EOF

$t->post_ok('/pingback' =>
      <<"EOF")->status_is(200)->content_like(qr/The source URI does not contain a link to the target URI, and so cannot be used as a source./);
<?xml version="1.0"?>
<methodCall>
    <methodName>pingback.ping</methodName>
    <params>
        <param><value><string>/source_uri_invalid</string></value></param>
        <param><value><string>http://localhost:$port/articles/2010/10/foo</string></value></param>
    </params>
</methodCall>
EOF

unlink "$FindBin::Bin/../articles/20101010-foo.md.pingbacks";
$t->post_ok(
    '/pingback' => <<"EOF")->status_is(200)->content_like(qr/Success/);
<?xml version="1.0"?>
<methodCall>
    <methodName>pingback.ping</methodName>
    <params>
        <param><value><string>/source_uri</string></value></param>
        <param><value><string>http://localhost:$port/articles/2010/10/foo</string></value></param>
    </params>
</methodCall>
EOF

$t->post_ok('/pingback' =>
      <<"EOF")->status_is(200)->content_like(qr/The pingback has already been registered./);
<?xml version="1.0"?>
<methodCall>
    <methodName>pingback.ping</methodName>
    <params>
        <param><value><string>/source_uri</string></value></param>
        <param><value><string>http://localhost:$port/articles/2010/10/foo</string></value></param>
    </params>
</methodCall>
EOF

$t->post_ok('/pingback' =>
      <<"EOF")->status_is(200)->content_like(qr/The pingback has already been registered./);
<?xml version="1.0"?>
<methodCall>
    <methodName>pingback.ping</methodName>
    <params>
        <param><value><string>/source_uri</string></value></param>
        <param><value><string>http://localhost:$port/articles/2010/10/foo.html</string></value></param>
    </params>
</methodCall>
EOF
unlink "$FindBin::Bin/../articles/20101010-foo.md.pingbacks";

undef $ENV{MOJO_HOME};
