#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 3;

use FindBin;
use lib "$FindBin::Bin/../../contrib/mojo/lib";

use Mojolicious::Lite;
use Test::Mojo;

app->helper(config => sub { {} });

push @{app->plugins->namespaces}, 'Bootylicious::Plugin';
plugin 'booty_helpers';

# Silence
app->log->level('debug');

get '/' => 'index';

my $t = Test::Mojo->new;

$t->get_ok('/')->status_is(200)->content_is(<<"EOF");
<img class="gravatar" height="40" src="http://www.gravatar.com/avatar/00000000000000000000000000000000?s=40" width="40" />
<img class="gravatar" height="40" src="http://www.gravatar.com/avatar/b03e2e03fea48f3aee2be87fcc4201a0?s=40" width="40" />
EOF

__DATA__
@@ index.html.ep
<%= gravatar %>
<%= gravatar 'vti@cpan.org' %>
