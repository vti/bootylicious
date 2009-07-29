#!/usr/bin/env perl

use Mojolicious::Lite;
use Mojo::Date;
use Pod::Simple::HTML;
require Time::Local;

my %config = (
    name  => $ENV{BOOTYLICIOUS_USER}  || 'whoami',
    email => $ENV{BOOTYLICIOUS_EMAIL} || '',
    title => $ENV{BOOTYLICIOUS_TITLE} || 'I am too lazy to set the title',
    description => $ENV{BOOTYLICIOUS_DESCR} || 'I do not know if I need this',
    articles_dir => $ENV{BOOTYLICIOUS_ARTICLESDIR} || 'articles',
    require_css => -r 'public/bootylicious.css' ? 1 : 0
);

get '/:index' => {index => 'index'} => 'index' => sub {
    my $c = shift;

    my $root = $c->app->home->rel_dir($config{articles_dir});

    my @articles;
    my $last_modified = Mojo::Date->new;

    if (opendir DIR, $root) {
        my @files = grep { -r "$root/$_" && m/\.pod$/ } readdir(DIR);
        closedir DIR;

        foreach my $file (@files) {
            my $data = _parse_article($c, "$root/$file");
            next unless $data;

            push @articles, $data;
        }

        @articles = sort { $b->{name} cmp $a->{name} } @articles;

        $last_modified = $articles[0]->{mtime};

        #return 1 unless _is_modified($c, $last_modified);

        $c->res->headers->header('Last-Modified' => $last_modified);
    }

    $c->stash(articles => \@articles, last_modified => $last_modified, config => \%config);
};

get '/articles/:year/:month/:day/:alias' => 'article' => sub {
    my $c = shift;

    my $root = $c->app->home->rel_dir($config{articles_dir});
    my $path = join('/',
        $root,
        $c->stash('year')
          . $c->stash('month')
          . $c->stash('day') . '-'
          . $c->stash('alias')
          . '.pod');

    return $c->app->static->serve_404($c) unless -r $path;

    my $last_modified = Mojo::Date->new((stat($path))[9]);

    my $data; $data = _parse_article($c, $path)
        or return $c->app->static->serve_404($c);

    #return 1 unless _is_modified($c, $last_modified);

    $c->stash(article => $data, template => 'article', config => \%config);

    $c->res->headers->header('Last-Modified' => Mojo::Date->new($last_modified));
};

sub _is_modified {
    my $c = shift;
    my ($last_modified) = @_;

    my $date = $c->req->headers->header('If-Modified-Since');
    return 1 unless $date;

    return 1 unless Mojo::Date->new($date)->epoch == $last_modified->epoch;

    $c->res->code(304);

    return 0;
}

my %_articles;
sub _parse_article {
    my $c = shift;
    my $path = shift;

    return $_articles{$path} if $_articles{$path};

    return unless $path =~ m/\/(\d\d\d\d)(\d\d)(\d\d)-(.*?)\.pod/;
    my ($year, $month, $day, $name) = ($1, $2, $3, $4);

    my $epoch = 0;
    eval { $epoch = Time::Local::timegm(0, 0, 0, $day, $month, $year); };
    return if $@ || $epoch < 0;

    my $parser = Pod::Simple::HTML->new;

    $parser->force_title('');
    $parser->html_header_before_title('');
    $parser->html_header_after_title('');
    $parser->html_footer('');

    my $title = '';
    my $content = '';;

    $parser->output_string(\$content);
    eval { $parser->parse_file($path) };
    return if $@;

    $title = $parser->get_title;

    return $_articles{$path} = {
        title   => $title,
        content => $content,
        mtime   => Mojo::Date->new((stat($path))[9]),
        created => Mojo::Date->new($epoch),
        year    => $year,
        month   => $month,
        day     => $day,
        name    => $name
    };
}

app->types->type(rss => 'application/rss+xml');

shagadelic;
__DATA__

@@ index.html.eplite
% my $self = shift;
% $self->stash(layout => 'wrapper');
% my $articles = $self->stash('articles');
<h1>Articles</h1>
<ul>
% foreach my $article (@$articles) {
    <li><a href="/articles/<%== join('/', $article->{year}, $article->{month}, $article->{day}, $article->{name}) %>.html"><%= $article->{title} || $article->{name} %></a>
    Created: <%= $article->{created} %></li>
% }
</ul>

@@ index.rss.eplite
% my $self = shift;
% my $articles = $self->stash('articles');
% my $last_modified = $self->stash('last_modified');
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xml:base="<%= $self->req->url->base %>"
    xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
        <title><%= $self->stash('config')->{title} %></title>
        <link><%= $self->req->url->base %></link>
        <description><%= $self->stash('config')->{description} %></description>
        <pubDate><%= $last_modified %></pubDate>
        <lastBuildDate><%= $last_modified %></lastBuildDate>
        <generator>Mojolicious::Lite</generator>
    </channel>
% foreach my $article (@$articles) {
% my $link = $self->url_for('article', article => $article->{name}, format => 'html')->to_abs;
    <item>
      <title><%== $article->{title} %></title>
      <link><%= $link %></link>
      <description><%== $article->{content} %></description>
      <pubDate><%= $article->{mtime} %></pubDate>
      <guid><%= $link %></guid>
    </item>
% }
</rss>

@@ article.html.eplite
% my $self = shift;
% $self->stash(layout => 'wrapper');
% my $article = $self->stash('article');
<%= $article->{content} %>

@@ layouts/wrapper.html.eplite
% my $self = shift;
% my $config = $self->stash('config');
<!html>
    <head>
        <title><%= $config->{title} %></title>
% if ($self->stash('config')->{require_css}) {
        <link rel="stylesheet" href="/bootylicious.css" type="text/css" />
% }
    </head>
    <body>
        <div id="body">
        <div id="header"><a href="/">Articles</a> (<a href="<%= $self->url_for('index', format => 'rss') %>">rss</a>)</div>

        <div id="content">
        <%= $self->render_inner %>
        </div>

        <div id="footer"><small>Powered by Mojolicious::Lite & Pod::Simple::HTML</small></div>
        </div>
    </body>
</html>
