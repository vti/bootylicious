package Bootylicious::Plugin::Search;

use strict;
use warnings;

use base 'Mojo::Base';

use Mojo::ByteStream;

__PACKAGE__->attr('before_context' => 20);
__PACKAGE__->attr('after_context'  => 20);
__PACKAGE__->attr('min_length'     => 2);
__PACKAGE__->attr('max_length'     => 256);

sub hook_init {
    my $self = shift;
    my $app = shift;

    my $r = $app->routes;

    $r->route('/search')
      ->to(callback => sub { my $c = shift; _search($self, $c) })
      ->name('search');
}

sub _search {
    my $self = shift;
    my $c = shift;

    my $q = $c->req->param('q');

    my $results = [];

    if (defined $q && length($q) < $self->min_length) {
        $c->stash(error => 'Has to be '
              . $self->min_length
              . ' characters minimal');
    }
    elsif (defined $q && length($q) > $self->max_length) {
        $c->stash(error => 'Has to be '
              . $self->max_length
              . ' characters maximal');
    }
    else {
        if (defined $q) {
            my ($articles) = main::get_articles;

            my $before_context = $self->before_context;
            my $after_context  = $self->after_context;

            foreach my $article (@$articles) {
                if ($article->{title}
                    =~ s/(\Q$q\E)/<font color="red">$1<\/font>/isg)
                {
                    push @$results, $article;
                }

                $article->{parts} = [];

                while ($article->{content}
                    =~ s/((?:.{$before_context})?\Q$q\E(?:.{$after_context})?)//is
                  )
                {
                    my $part = $1;
                    $part =~ s/<.*?>//isg;
                    $part =~ s/^[^\s]+//;
                    $part =~ s/[^\s]+$//;
                    $part =
                      Mojo::ByteStream->new($part)->html_escape->to_string;
                    $part =~ s/(\Q$q\E)/<font color="red">$1<\/font>/isg;
                    push @{$article->{parts}}, $part;
                }
            }
        }
    }

    $c->stash(
        articles       => $results,
        config         => main::config(),
        format         => 'html',
        template_class => __PACKAGE__,
        layout         => 'wrapper'
    );
}

1;
__DATA__

@@ search.html.epl
% my $self = shift;
% my $articles = $self->stash('articles');
% $self->stash(template_class => 'main');
<div style="text-align:center;padding:2em">
<form method="get">
<input type="text" name="q" value="<%= $self->req->param('q') || '' %>" />
<input type="submit" value="Search" />
% if (my $error = $self->stash('error')) {
<div style="color:red"><%= $error %></div>
% }
</form>
</div>
% if (!$self->stash('error') && $self->req->param('q')) {
<h1>Search results: <%= @$articles %></h1>
<br />
% }
% foreach my $article (@$articles) {
<div class="text">
    <a href="<%== $self->url_for('article', year => $article->{year}, month => $article->{month}, alias => $article->{name}, format => 'html') %>"><%= $article->{title} %></a><br />
    <div class="created"><%= $article->{created_format} %></div>
%   foreach my $part (@{$article->{parts}}) {
    <span style="font-size:small"><%= $part %></span> ...
% }
</div>
% }
