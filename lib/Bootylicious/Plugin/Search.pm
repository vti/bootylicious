package Bootylicious::Plugin::Search;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Mojo::ByteStream 'b';

sub register {
    my ($self, $app, $conf) = @_;

    $conf ||= {};

    $conf->{'before_context'} ||= 20;
    $conf->{'after_context'}  ||= 20;
    $conf->{'min_length'}     ||= 2;
    $conf->{'max_length'}     ||= 256;

    $app->routes->route('/search')->via('GET')
      ->to(cb => sub { my $c = shift; _search($app, $c, $conf) })
      ->name('search');
}

sub _search {
    my $app  = shift;
    my $c    = shift;
    my $conf = shift;

    $c->stash(template_class => __PACKAGE__);

    my $q = $c->req->param('q');
    return unless defined $q;

    my $min_length = $conf->{min_length};
    my $max_length = $conf->{max_length};

    if (length($q) < $min_length) {
        $c->stash(error => qq/Query must be $min_length characters minimum/);
    }
    elsif (length($q) > $max_length) {
        $c->stash(error => qq/Query must be $max_length characters maximum/);
    }
    else {
        my $articles = $c->get_articles_by_query(
            $q,
            before_context => $conf->{before_context},
            after_context  => $conf->{after_context}
        );

        my $pager = $c->get_pager($articles, timestamp => $c->param('timestamp'));

        $c->stash(
            total    => $articles->size,
            articles => $pager->articles,
            pager    => $pager
        );
    }
}

1;
__DATA__

@@ search.html.ep
% stash template_class => 'main', title => 'Search';
<div style="text-align:center;padding:2em">
<%= form_for 'search', method => 'get' => begin %>
    <%= input 'q', style => 'font-size:150%' %>
    % if (my $error = stash 'error') {
    <div style="color:red"><%= $error %></div>
    % }
<% end %>
</div>
% if (my $articles = stash 'articles') {
<h1>Search results: <%== stash 'total' %></h1>
<br />
% while (my $article = $articles->next) {
<div class="text">
    <%= link_to_article $article %><br />
    <div class="created"><%= date $article->created %></div>
    % foreach my $part (@{$article->content || []}) {
     <span style="font-size:small"><%== $part %></span> ...
    % }
</div>
% }

% my $pager = stash 'pager';
    <div id="pager">
        <%= link_to_page 'search', $pager->prev_timestamp => {query => {q => param 'q'}} => {%><span class="arrow">&larr; </span><%= strings 'later' %><%}%>
        <%= link_to_page 'search', $pager->next_timestamp => {query => {q => param 'q'}} => {%><%= strings 'earlier' %><span class="arrow"> &rarr;</span><%}%>
    </div>
% }
