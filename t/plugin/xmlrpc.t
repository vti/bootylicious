#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 36;

use FindBin;
use Mojo::Client;
use Mojo::Transaction::Single;
use Bootylicious::Plugin::Xmlrpc;
use Protocol::XMLRPC::MethodCall;

use FindBin;
require "$FindBin::Bin/../../bootylicious.pl";

my $xmlrpc;

eval {$xmlrpc = Bootylicious::Plugin::Xmlrpc->new()};
like($@, qr/Username and password are required/);

undef $@;

eval {$xmlrpc = Bootylicious::Plugin::Xmlrpc->new(username => 'foo')};
like($@, qr/Username and password are required/);

undef $@;

$xmlrpc =
  Bootylicious::Plugin::Xmlrpc->new(username => 'foo', password => 'bar');
ok($xmlrpc);

my $app = app();
$app->log->level('fatal');

my $articlesdir = "$FindBin::Bin/xmlrpc";
main::config(title => 'Foobar blog', articlesdir => $articlesdir);

mkdir $articlesdir;
unlink ($_) for glob("$articlesdir/*pod");

$xmlrpc->hook_init($app);

my $client = Mojo::Client->new;

my $tx = Mojo::Transaction::Single->new_get('/xmlrpc');
$client->process_app($app, $tx);
is($tx->res->code, 404);

my $r;

$r = _call('unknownMethod');
ok($r->fault);

$r = _call('blogger.getUsersBlogs', 'some api key', 'foo', 'bar');
ok($r->param);
is($r->param->data->[0]->value->{blogid}, 'bootylicious');
is($r->param->data->[0]->value->{blogName}, 'Foobar blog');

$r = _call('metaWeblog.getCategories', 'bootylicious', 'foo', 'bar');
is_deeply($r->param->value, {});

$r = _call('metaWeblog.getRecentPosts', 'bootylicious', 'foo', 'bar', 10);
is(scalar @{$r->param->data}, 0);

$r =
  _call('metaWeblog.newPost', 'bootylicious', 'foo', 'bar',
    {title => 'foo', description => 'bar', categories => [qw/one two/]}, 'true');
my @time = localtime(time);
my $postid = ($time[5] + 1900) . '/' . sprintf("%02d", $time[4]) . '/' . 'foo';
ok($r->param);
is($r->param->value, $postid);

$r = _call('metaWeblog.getPost', 'unknown', 'foo', 'bar');
ok($r->fault);
is($r->fault_string, 'Article not found');

$r = _call('metaWeblog.getPost', $postid, 'foo', 'bar');
ok($r->param);
is($r->param->value->{title}, 'foo');
like($r->param->value->{description}, qr/bar/);
is_deeply($r->param->value->{categories}, [qw/one two/]);

diag('Expiring cache');
sleep(1);
$r =
  _call('metaWeblog.editPost', $postid, 'foo', 'bar',
    {title => 'bar', description => 'foo', categories => [qw/three four/]},
    'true');
ok($r->param);
is($r->param->value, 'true');

$r = _call('metaWeblog.getPost', $postid, 'foo', 'bar');
ok($r->param);
is($r->param->value->{title}, 'bar');
like($r->param->value->{description}, qr/foo/);
is_deeply($r->param->value->{categories}, [qw/three four/]);

$r = _call('metaWeblog.getCategories', 'bootylicious', 'foo', 'bar');
ok($r->param);
is_deeply(
    $r->param->value,
    {   three => {
            description => 'three',
            htmlUrl     => '/tags/three.html',
            rssUrl      => '/tags/three.rss'
        },
        four => {
            description => 'four',
            htmlUrl     => '/tags/four.html',
            rssUrl      => '/tags/four.rss'
        }
    }
);

sub _call {
    my ($name, @params) = @_;

    my $method_call = Protocol::XMLRPC::MethodCall->new(name => $name);
    $method_call->add_param($_) for @params;

    $tx = Mojo::Transaction::Single->new_post('/xmlrpc');
    $tx->req->body($method_call);
    $client->process_app($app, $tx);
    is($tx->res->code, 200);

    return Protocol::XMLRPC::MethodResponse->parse($tx->res->body);
}
