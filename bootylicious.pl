#!/usr/bin/env perl

BEGIN { use FindBin; use lib "$FindBin::Bin/mojo/lib" }

use Mojolicious::Lite;
use Mojo::Date;
use Mojo::Template;
use Mojo::ByteStream;
use Mojo::Loader;
use Mojo::JSON;
use Pod::Simple::HTML;
require Time::Local;
require File::Basename;
use Mojo::ByteStream;

my %config = (
    author => $ENV{BOOTYLICIOUS_AUTHOR} || 'whoami',
    email  => $ENV{BOOTYLICIOUS_EMAIL}  || '',
    title  => $ENV{BOOTYLICIOUS_TITLE}  || 'Just another blog',
    about  => $ENV{BOOTYLICIOUS_ABOUT}  || 'Perl hacker',
    descr  => $ENV{BOOTYLICIOUS_DESCR}  || 'I do not know if I need this',
    articlesdir => $ENV{BOOTYLICIOUS_ARTICLESDIR} || 'articles',
    pagesdir => $ENV{BOOTYLICIOUS_PAGESDIR} || 'pages',
    draftsdir => $ENV{BOOTYLICIOUS_DRAFTSDIR} || 'drafts',
    publicdir => $ENV{BOOTYLICIOUS_PUBLICDIR}
      || undef,    # defaults to 'public',
    templatesdir => $ENV{BOOTYLICIOUS_TEMPLATESDIR}
      || undef,    # defaults to 'templates'
    footer => $ENV{BOOTYLICIOUS_FOOTER}
      || 'Powered by <a href="http://getbootylicious.org">Bootylicious</a>',
    menu => [
        index   => '/index.html',
        tags    => '/tags.html',
        archive => 'archive.html'
    ],
    theme     => '',
    cuttag    => '[cut]',
    pagelimit => 10,
    meta      => [],
);

my %hooks = (
    preinit  => [],
    init     => [],
    finalize => []
);

_read_config_from_file(app->home->rel_file('bootylicious.conf'));

_load_plugins($config{plugins});

_call_hook(app, 'preinit');

sub config {
    if (@_) {
        %config = (%config, @_);
    }

    return \%config;
}

sub index {
    my $c = shift;

    my $timestamp = $c->req->param('timestamp') || 0;

    my $article;
    my ($articles, $pager) =
      get_articles(limit => $config{pagelimit}, timestamp => $timestamp);

    my $last_modified;
    if (@$articles) {
        $article = $articles->[0];

        $last_modified = $article->{modified};

        return 1 unless _is_modified($c, $last_modified);
    }

    my $later = 0;

    $c->stash(
        config   => \%config,
        article  => $article,
        articles => $articles,
        pager    => $pager
    );

    $c->res->headers->header('Last-Modified' => Mojo::Date->new($last_modified));

    $c->stash(template => 'index');

    $c->render;

    _call_hook($c, 'finalize');
}

get '/' => \&index => 'root';
get '/index' => \&index => 'index';

get '/archive' => sub {
    my $c = shift;

    my $root = $c->app->home;

    my $last_modified = Mojo::Date->new;

    my ($articles) = get_articles(limit => 0);
    if (@$articles) {
        $last_modified = $articles->[0]->{modified};

        return 1 unless _is_modified($c, $last_modified);
    }

    $c->res->headers->header('Last-Modified' => $last_modified);

    $c->stash(
        articles      => $articles,
        last_modified => $last_modified,
        config        => \%config
    );

    $c->render;

    _call_hook($c, 'finalize');
} => 'archive';

get '/tags/:tag' => sub {
    my $c = shift;

    my $tag = $c->stash('tag');

    my ($articles) = get_articles(limit => 0);

    $articles = [
        grep {
            grep {/^$tag$/} @{$_->{tags}}
          } @$articles
    ];

    my $last_modified = Mojo::Date->new;
    if (@$articles) {
        $last_modified = $articles->[0]->{modified};

        return 1 unless _is_modified($c, $last_modified);
    }

    $c->stash(
        config        => \%config,
        articles      => $articles,
        last_modified => $last_modified
    );

    $c->res->headers->header('Last-Modified' => Mojo::Date->new($last_modified));

    if ($c->stash('format') && $c->stash('format') eq 'rss') {
        $c->stash(template => 'index');
    }

    $c->render;

    _call_hook($c, 'finalize');
} => 'tag';

get '/tags' => sub {
    my $c = shift;

    my $tags = get_tags();

    $c->stash(config => \%config, tags => $tags);

    $c->render;

    _call_hook($c, 'finalize');
} => 'tags';

get '/articles/:year/:month/:alias' => sub {
    my $c = shift;

    my $articleid =
      $c->stash('year') . '/' . $c->stash('month') . '/' . $c->stash('alias');

    my $article = get_article($articleid);
    unless ($article) {
        $c->stash(rendered => 1);
        $c->app->static->serve_404($c);
        return 1;
    }

    return 1 unless _is_modified($c, $article->{modified});

    $c->stash(article => $article, template => 'article', config => \%config);

    $c->res->headers->header(
        'Last-Modified' => Mojo::Date->new($article->{modified}));

    $c->render;

    _call_hook($c, 'finalize');
} => 'article';

get '/pages/:pageid' => sub {
    my $c = shift;

    my $pageid = $c->stash('pageid');

    my $page = get_page($pageid);
    unless ($page) {
        $c->stash(rendered => 1);
        $c->app->static->serve_404($c);
        return 1;
    }

    #return 1 unless _is_modified($c, $page->{modified});

    $c->stash(page => $page, config => \%config);

    $c->res->headers->header(
        'Last-Modified' => Mojo::Date->new($page->{modified}));

    $c->render;

    _call_hook($c, 'finalize');
} => 'page';

get '/drafts/:draftid' => sub {
    my $c = shift;

    my $draftid = $c->stash('draftid');

    my $draft = get_draft($draftid);
    unless ($draft) {
        $c->stash(rendered => 1);
        $c->app->static->serve_404($c);
        return 1;
    }

    #return 1 unless _is_modified($c, $page->{modified});

    $c->stash(draft => $draft, config => \%config);

    $c->res->headers->header(
        'Last-Modified' => Mojo::Date->new($draft->{modified}));

    $c->render;

    _call_hook($c, 'finalize');
} => 'draft';

sub theme {
    my $publicdir = app->home->rel_dir($config{publicdir});

    # CSS, JS auto import
    foreach my $type (qw/css js/) {
        $config{$type} =
          [map { s/^$publicdir\///; $_ }
              glob("$publicdir/bootylicious/themes/$config{theme}/*.$type")];
    }
}

sub _read_config_from_file {
    my ($conf_file) = @_;

    if (-e $conf_file) {
        if (open FILE, "<", $conf_file) {
            my @lines = <FILE>;
            close FILE;

            my $line = '';
            foreach my $l (@lines) {
                next if $l =~ m/^#/;
                $line .= $l;
            }
            %config = (%config, %{Mojo::JSON->new->decode($line)});

            unshift @INC, $_
              for (
                ref $config{perl5lib} eq 'ARRAY'
                ? @{$config{perl5lib}}
                : $config{perl5lib});
        }
    }

    $ENV{SCRIPT_NAME} = $config{base} if $config{base};

    # set proper templates base dir, if defined
    app->renderer->root(app->home->rel_dir($config{templatesdir})) 
        if defined $config{templatesdir};

    # set proper public base dir, if defined
    app->static->root(app->home->rel_dir($config{publicdir}))
        if defined $config{publicdir};
}

sub _load_plugins {
    my $plugins_arrayref = shift;

    my $lib_dir = app->home->rel_dir('lib');
    push @INC, $lib_dir;

    my $prev;
    while (my $plugin = shift @$plugins_arrayref) {
        if (ref $plugin eq 'HASH') {
            _load_plugin($prev => $plugin);
        }
        elsif ($prev || !@$plugins_arrayref) {
            _load_plugin($plugin);
        }
        $prev = $plugin;
    }
}

sub _load_plugin {
    my ($class, $args) = @_;

    my $loader = Mojo::Loader->new;

    $class = Mojo::ByteStream->new($class)->camelize;
    $class = "Bootylicious::Plugin::$class";

    app->log->debug("Loading plugin '$class'");

    if (my $e = $loader->load($class)) {
        if (ref $e) {
            app->log->error($e);
        }
        else {
            app->log->error("Plugin not found: $class");
        }

        return;
    }

    unless ($class->can('new')) {
        app->log->error(qq|Can't locate object method "new" via plugin '$class'|);
        return;
    }

    $args ||= {};
    my $instance = $class->new(%$args);

    foreach my $hook (keys %hooks) {
        next unless $class->can("hook_$hook");

        app->log->debug("Registering hook '$class\::hook_$hook'");

        push @{$hooks{$hook}}, $instance;
    }
}

sub _call_hook {
    my $c = shift;
    my $hook = shift;

    my $method = "hook_$hook";
    $_->$method($c) foreach @{$hooks{$hook}};
}

sub _is_modified {
    my $c = shift;
    my ($last_modified) = @_;

    my $date = $c->req->headers->header('If-Modified-Since');
    return 1 unless $date;

    return 1 unless Mojo::Date->new($date)->epoch == $last_modified->epoch;

    $c->res->code(304);
    $c->stash(rendered => 1);

    return 0;
}

sub get_tags {
    my $tags = {};

    my ($articles) = get_articles(limit => 0);

    foreach my $article (@$articles) {
        foreach my $tag (@{$article->{tags}}) {
            $tags->{$tag}->{count} ||= 0;
            $tags->{$tag}->{count}++;
        }
    }

    return $tags;
}

sub get_articles {
    my %params = @_;
    $params{limit} ||= 0;

    my $root =
      ($config{articlesdir} =~ m/^\//)
      ? $config{articlesdir}
      : app->home->rel_dir($config{articlesdir});

    my $pager = {};

    my @files = sort { $b cmp $a } glob($root . '/*.*');

    if ($params{limit}) {
        my $min = 0;

        if ($params{timestamp}) {
            my $i = 0;
            foreach my $file (@files) {
                File::Basename::basename($file) =~ m/^([^\-]+)-/;

                if ($1 le $params{timestamp}) {
                    $min = $i;
                    last;
                }

                $i++;
            }
        }

        my $max = $min + $params{limit};

        if ($min > $params{limit} - 1 && $files[$min - $params{limit}]) {
            $pager->{prev} = $1
              if File::Basename::basename($files[$min - $params{limit}])
                  =~ m/^([^\-]+)-/;
        }

        if ($max < scalar(@files) && $files[$max]) {
            $pager->{next} = $1
              if File::Basename::basename($files[$max]) =~ m/^([^\-]+)-/;
        }

        @files = splice(@files, $min, $params{limit});
    }

    my @articles;
    foreach my $file (@files) {
        my $data = _parse_article($file);
        next unless $data && %$data;

        push @articles, $data;
    }

    return (\@articles, $pager);
}

sub get_article {
    my $articleid = shift;
    return unless $articleid;

    my ($year, $month, $alias) = split('/', $articleid);
    return unless $year && $month && $alias;

    my $root =
      ($config{articlesdir} =~ m/^\//)
      ? $config{articlesdir}
      : app->home->rel_dir($config{articlesdir});

    my @files =
      glob( $root . '/'
          . $year
          . $month . '*-'
          . $alias
          . ".*");

    if (@files > 1) {
        app->log->warn('More then one article is available '
              . 'at the same year/month and name');
    }
    my $path = $files[0];
    return unless $path && -r $path;

    return _parse_article($path);
}

sub get_draft {
    my $alias = shift;
    return unless $alias;

    my $root =
      ($config{draftsdir} =~ m/^\//)
      ? $config{draftsdir}
      : app->home->rel_dir($config{draftsdir});

    my @files = glob($root . '/' . '*' . $alias . ".*");

    if (@files > 1) {
        app->log->warn('More then one draft is available '
              . 'with the same alias');
    }
    my $path = $files[0];
    return unless $path && -r $path;

    return _parse_article($path);
}

sub get_page {
    my $pageid = shift;
    return unless $pageid;

    my $root =
      ($config{pagesdir} =~ m/^\//)
      ? $config{pagesdir}
      : app->home->rel_dir($config{pagesdir});

    my @files = glob($root . '/' . $pageid . ".*");

    if (@files > 1) {
        app->log->warn('More then one page is available '
              . 'with the same extension');
    }
    my $path = $files[0];
    return unless $path && -r $path;

    return _parse_article($path);
}

my %_articles;
sub _parse_article {
    my $path = shift;
    return unless $path;

    my $modified = (stat($path))[9];

    return $_articles{$path}
      if $_articles{$path} && $_articles{$path}->{modified} == $modified;

    my ($name, $ext) = ($path =~ m/\/([^\/]+)\.([^.]+)$/);

    my ($year, $month, $day, $hour, $minute, $second);
    if ($name =~ s/(\d\d\d\d)(\d\d)(\d\d)(?:T(\d\d):?(\d\d):?(\d\d))?-//) {
        ($year, $month, $day, $hour, $minute, $second) =
          ($1, $2, $3, ($4 || '00'), ($5 || '00'), ($6 || '00'));

        $second ||= 0;
        $minute ||= 0;
        $hour   ||= 0;
    }
    else {
        ($second, $minute, $hour, $day, $month, $year) =
          gmtime($modified);

        $year += 1900;
        $month += 1;
    }

    my $timestamp =
        $year
      . sprintf('%02d', $month)
      . sprintf('%02d', $day) . 'T'
      . sprintf('%02d', $hour) . ':'
      . sprintf('%02d', $minute) . ':'
      . sprintf('%02d', $second);

    my $created = 0;
    eval {
        $created =
          Time::Local::timegm($second, $minute, $hour, $day, $month - 1,
            $year - 1900);
    };
    if ($@ || $created < 0) {
        app->log->debug("Ignoring $path: wrong timestamp");
        return;
    }

    unless (open FILE, "<:encoding(UTF-8)", $path) {
        app->log->error("Can't open file: $path: $!");
        return;
    }
    my $string = join("", <FILE>);
    close FILE;

    my $parser = _get_parser($ext);
    return unless $parser;

    my $metadata = _parse_metadata(\$string);

    my $cuttag = $config{cuttag};
    my ($head, $tail) = ($string, '');
    my $preview_link = '';
    if ($head =~ s{(.*?)\Q$cuttag\E(?: (.*?))?(?:\n|\r|\n\r)(.*)}{$1}s) {
        $tail = $3;
        $preview_link = $2 || 'Keep reading';
    }

    my $data = $parser->($head, $tail);
    unless ($data) {
        app->log->debug("Ignoring $path: parser error");
        return;
    }

    my $content =
        $data->{tail}
      ? $data->{head} . '<a name="cut"></a>' . $data->{tail}
      : $data->{head};
    my $preview = $data->{tail} ? $data->{head} : '';

    return $_articles{$path} = {
        path            => $path,
        name            => $name,
        created         => $created,
        modified        => $modified,
        modified_format => _format_date($modified),
        created_format  => _format_date($created),
        timestamp       => $timestamp,
        year            => $year,
        month           => $month,
        day             => $day,
        hour            => $hour,
        minute          => $minute,
        second          => $second,
        title           => $metadata->{title} || $name,
        link            => $metadata->{link} || '',
        tags            => $metadata->{tags} || [],
        preview         => $preview,
        preview_link    => $preview_link,
        content         => $content
    };
}

my %_parsers;
sub _get_parser {
    my $ext = shift;

    my $parser = \&_parse_article_pod;
    if ($ext eq 'epl') {
        $parser = sub {
            my ($head_string, $tail_string) = @_;

            my $head  = '';
            my $tail  = '';

            my $mt = Mojo::Template->new;

            $head = $mt->render($head_string);

            if ($tail_string) {
                $tail = $mt->render($tail_string);
            }

            return {
                head  => $head,
                tail  => $tail
            };
          }
    }
    elsif ($ext ne 'pod') {
        my $parser_class =
          'Bootylicious::Parser::' . Mojo::ByteStream->new($ext)->camelize;

        if ($_parsers{$parser_class}) {
            $parser = $_parsers{$parser_class};
        }
        else {
            eval "require $parser_class";
            if ($@) {
                app->log->error($@);
                return;
            }
            #my $loader = Mojo::Loader->new;
            #if (my $e = $loader->load($parser_class)) {
                #if (ref $e) {
                    #$c->app->log->error($e);
                #}
                #else {
                    #$c->app->log->error("Unknown parser: $parser_class");
                #}
                #return;
            #}

            $parser = $_parsers{$parser_class} = $parser_class->new->parser_cb;
        }
    }

    return $parser;
}

sub _parse_metadata {
    my $string = shift;

    $$string =~ s/^(.*?)(?:\n\n|\n\r\n\r|\r\r)//s;
    return {} unless $1;

    my $data = $1;

    my $metadata = {};
    while ($data =~ s/^(.*?):\s*(.*?)(?:\n|\n\r|\r|$)//s) {
        my $key = lc $1;
        my $value = $2;

        if ($key eq 'tags') {
            my $tmp = $value || '';
            $value = [];
            @$value = map { s/^\s+//; s/\s+$//; $_ } split(/,/, $tmp);
        }

        $metadata->{$key} = $value;
    }

    return $metadata;
}

sub _parse_article_pod {
    my ($head_string, $tail_string) = @_;

    my $parser = Pod::Simple::HTML->new;

    $parser->force_title('');
    $parser->html_header_before_title('');
    $parser->html_header_after_title('');
    $parser->html_footer('');

    my $title = '';
    my $head  = '';
    my $tail  = '';

    $parser->output_string(\$head);
    $head_string = "=pod\n\n$head_string";
    eval { $parser->parse_string_document($head_string) };
    return if $@;

    # Hacking
    $head =~ s{<a name='___top' class='dummyTopAnchor'\s*></a>\n}{}g;
    $head =~ s{<a class='u'.*?name=".*?"\s*>(.*?)</a>}{$1}sg;
    $head =~ s{^\s*<h1>NAME</h1>\s*<p>(.*?)</p>}{}sg;
    $title = $1;

    if ($tail_string) {
        $tail_string = "=pod\n$tail_string";
        my $parser = Pod::Simple::HTML->new;

        $parser->force_title('');
        $parser->html_header_before_title('');
        $parser->html_header_after_title('');
        $parser->html_footer('');

        $parser->output_string(\$tail);
        eval { $parser->parse_string_document($tail_string) };
        return if $@;

        $tail =~ s{<a name='___top' class='dummyTopAnchor'\s*></a>\n}{}g;
        $tail =~ s{<a class='u'.*?name=".*?"\s*>(.*?)</a>}{$1}sg;
    }

    my $link = '';
    if ($head =~ s{^\s*<h1>LINK</h1>\s*<p>(.*?)</p>}{}sg) {
        $link = $1;
    }

    my $tags = [];
    if ($head =~ s{^\s*<h1>TAGS</h1>\s*<p>(.*?)</p>}{}sg) {
        my $list = $1; $list =~ s/(?:\r|\n)*//gs;
        @$tags = map { s/^\s+//; s/\s+$//; $_ } split(/,/, $list);
    }

    return {
        title => $title,
        link  => $link,
        tags  => $tags,
        head  => $head,
        tail  => $tail
    };
}

sub _format_date {
    my $date = shift;

    $date = Mojo::Date->new($date)->to_string;

    $date =~ s/ [^ ]*? GMT$//;

    return $date;
}

_call_hook(app, 'init');

theme if $config{'theme'};

shagadelic(@ARGV ? @ARGV : 'cgi');

__DATA__

@@ index.html.epl
% my $self = shift;
% my $articles = $self->stash('articles');
% my $pager = $self->stash('pager');
% $self->stash(layout => 'wrapper');
% foreach my $article (@{$articles}) {
    <div class="text">
        <h1 class="title"><%= '&raquo;' if $article->{link} %> <a
        href="<%= $article->{link} || $self->url_for('article', year => $article->{year}, month => $article->{month}, alias => $article->{name}, format => 'html') %>"><%= $article->{title} %></a></h1>
        <div class="created"><%= $article->{created_format} %></div>
        <div class="tags">
% foreach my $tag (@{$article->{tags}}) {
        <a href="<%= $self->url_for('tag', tag => $tag) %>"><%= $tag %></a>
% }
        </div>
% if ($article->{preview}) {
        <%= $article->{preview} %>
        <div class="more">&rarr; <a href="<%== $self->url_for('article', year => $article->{year}, month => $article->{month}, alias => $article->{name}, format => 'html') %>#cut"><%= $article->{preview_link} %></a></div>
% }
% else {
        <%= $article->{content} %>
% }
    </div>
% }

<div id="pager">
% if ($pager->{prev}) {
    &larr; <a href="<%= $self->url_for('index',format=>'html') %>?timestamp=<%= $pager->{prev} %>">Earlier</a>
% }
% else {
<span class="notactive">
&larr; Earlier
</span>
% }

% if ($pager->{next}) {
    <a href="<%= $self->url_for('index',format=>'html') %>?timestamp=<%= $pager->{next} %>">Later</a> &rarr;
% }
% else {
<span class="notactive">
Later &rarr;
</span>
% }
</div>

@@ archive.html.epl
% my $self = shift;
% $self->stash(layout => 'wrapper');
% $self->stash(title => 'Archive');
% my $articles = $self->stash('articles');
% my $tmp;
% my $new = 0;
<div class="text">
<h1>Archive</h1>
<br />
% foreach my $article (@$articles) {
%     if (!$tmp || $article->{year} ne $tmp->{year}) {
    <%= "</ul>" if $tmp %>
    <b><%= $article->{year} %></b>
<ul>
%     }

    <li>
        <a href="<%== $self->url_for('article', year => $article->{year}, month => $article->{month}, alias => $article->{name}) %>"><%= $article->{title} %></a><br />
        <div class="created"><%= $article->{created_format} %></div>
    </li>

%     $tmp = $article;
% }
</div>

@@ index.rss.epl
% my $self = shift;
% my $articles = $self->stash('articles');
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xml:base="<%= $self->req->url->base %>"
    xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
        <title><%= $self->stash('config')->{title} %></title>
        <link><%= $self->req->url->base %></link>
        <description><%= $self->stash('config')->{descr} %></description>
        <pubDate><%= $articles->[0]->{created} %></pubDate>
        <lastBuildDate><%= $articles->[0]->{created} %></lastBuildDate>
        <generator>Mojolicious::Lite</generator>
% foreach my $article (@$articles) {
% my $link = $self->url_for('article', year => $article->{year}, month => $article->{month}, alias => $article->{name}, format => 'html')->to_abs;
    <item>
      <title><%== $article->{title} %></title>
      <link><%= $link %></link>
% if ($article->{preview}) {
      <description><%== $article->{preview} %></description>
% }
% else {
      <description><%== $article->{content} %></description>
% }
% foreach my $tag (@{$article->{tags}}) {
      <category><%= $tag %></category>
% }
      <pubDate><%= $article->{created} %></pubDate>
      <guid><%= $link %></guid>
    </item>
% }
    </channel>
</rss>

@@ tags.html.epl
% my $self = shift;
% $self->stash(layout => 'wrapper');
% my $tags = $self->stash('tags');
% $self->stash(title => 'Tags');
<div class="text">
<h1>Tags</h1>
<br />
<div class="tags">
% foreach my $tag (keys %$tags) {
<a href="<%= $self->url_for('tag', tag => $tag, format => 'html') %>"><%= $tag %></a><sub>(<%= $tags->{$tag}->{count} %>)</sub>
% }
</div>
</div>

@@ tag.html.epl
% my $self = shift;
% $self->stash(layout => 'wrapper');
% my $tag = $self->stash('tag');
% $self->stash(title => $tag);
% my $articles = $self->stash('articles');
<div class="text">
<h1>Tag <%= $tag %>
<sup><a href="<%= $self->url_for('tag',tag=>$tag,format=>'rss') %>"><img src="data:image/png;base64,
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJ
bWFnZVJlYWR5ccllPAAAAlJJREFUeNqkU0toU0EUPfPJtOZDm9gSPzWVKloXgiCCInXTRTZVQcSN
LtyF6qILFwoVV+7EjR9oFy7VlSAVF+ouqMWWqCCIrbYSosaARNGmSV7ee+OdyUsMogtx4HBn5t1z
7twz85jWGv8zZHaUmRjlHBnBkRYSCSnog/wzuECZMzxgDNPEW5E0ASHTl4qf6h+KD6iwUpwyuRCw
kcCCNSPoRsNZKeS31D8WTOHLkqoagbQhV+sV1fDqEJQoidSCCMiMjskZU9HU4AAJpJsC0gokTGVD
XnfhA0DRL7+Hn38M/foOeOUzOJEZs+2Cqy5F1iXs3PZLYEGl+ux1NF7eAmpfIXedQOjYbYgdh9tk
Y3oTsDAnNCewPZqF8/SKjdqs+7aCj5wFDkwSlUEvzFgyPK8twNvuBv3GzixgzfgcQmNXqW/68IgE
is+BvRPQ0fXE9eC7Lvy/Cfi5G8DSQ7DkTrCxKbrgJPSTS5TUDQwfgWvIBO0Dvv+bgPFAz12Dzl4E
7p5svpQ9p6HLy9DFF2CD+9sCHpG9DgHHeGAExDglZnLAj09APgts2N089pdFsPjmXwIuHAJk8JKL
rXtuDWtWtQwWiliScFapQJedKxKsVFA0KezVUeMvprcfHDkua6uRzqsylQ2hE2ZPqXAld+/tTfIg
I56VgNG1SDkuhmIb+3tELCLRTYYpRdVDFpwgCJL2fJfXFufLS4Xl6v3z7zBvXkdqUxjJc8M4tC2C
fdDoNe62XPaCaOEBVOjbm++YnSphpuSiZAR6CFQS4h//ZJJD7acAAwCdOg/D5ZiZiQAAAABJRU5E
rkJggg==" alt="RSS" /></a></sup>
</h1>
<br />
% foreach my $article (@$articles) {
        <a href="<%== $self->url_for('article', year => $article->{year}, month => $article->{month}, alias => $article->{name}) %>"><%= $article->{title} %></a><br />
        <div class="created"><%= $article->{created_format} %></div>
% }
</div>

@@ article.html.epl
% my $self = shift;
% $self->stash(layout => 'wrapper');
% my $article = $self->stash('article');
% $self->stash(title => $article->{title});
<div class="text">
<h1 class="title">
% if ($article->{link}) {
&raquo; <a href="<%= $article->{link} %>"><%= $article->{title} %></a>
% } else {
<%= $article->{title} %>
% }
</h1>
<div class="created"><%= $article->{created_format} %>
% if ($article->{created} != $article->{modified}) {
, modified <span class="modified"><%= $article->{modified_format} %></span>
% }
</div>
<div class="tags">
% foreach my $tag (@{$article->{tags}}) {
<a href="<%= $self->url_for('tag', tag => $tag, format => 'html') %>"><%= $tag %></a>
% }
</div>
<%= $article->{content} %>
</div>

@@ page.html.epl
% my $self = shift;
% $self->stash(layout => 'wrapper');
% my $page = $self->stash('page');
% $self->stash(title => $page->{title});
<div class="text">
<h1 class="title">
<%= $page->{title} %>
</h1>
<%= $page->{content} %>
</div>

@@ draft.html.epl
% my $self = shift;
% $self->stash(layout => 'wrapper');
% my $draft = $self->stash('draft');
% $self->stash(title => $draft->{title});
<div class="text">
<h1 class="title">
<%= $draft->{title} %>
</h1>
<%= $draft->{content} %>
</div>

@@ layouts/wrapper.html.epl
% my $self = shift;
% my $config = $self->stash('config');
% $self->res->headers->content_type('text/html; charset=utf-8');
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
    <head>
        <title><%= $self->stash('title') . ' / ' if $self->stash('title') %><%= $config->{title} %></title>
        <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
% foreach my $meta (@{$config->{meta}}) {
        <meta <%= "$_=\"$meta->{$_}\" " for keys %$meta %>/>
% }
% foreach my $file (@{$config->{css}}) {
        <link rel="stylesheet" href="/<%= $file %>" type="text/css" />
% }
% if (!@{$config->{css}}) {
        <style type="text/css">
            html, body {height: 100%;margin:0}
            body {background: #fff;font-family: "Helvetica Neue", Arial, Helvetica, sans-serif;}
            h1,h2,h3,h4,h5 {font-family: times, "Times New Roman", times-roman, georgia, serif; line-height: 40px; letter-spacing: -1px; color: #444; margin: 0 0 0 0; padding: 0 0 0 0; font-weight: 100;}
            a,a:active {color:#555}
            a:hover{color:#000}
            a:visited{color:#000}
            img{border:0px}
            pre{border:2px solid #ccc;background:#eee;padding:2em}
            #body {width:65%;min-height:100%;height:auto !important;height:100%;margin:0 auto -6em;}
            #header {text-align:center;padding:2em 0em 0.5em 0em;border-bottom: 1px solid #000}
            h1#title{font-size:3em}
            h2#descr{font-size:1.5em;color:#999}
            span#author {font-weight:bold}
            span#about {font-style:italic}
            #menu {padding-top:1em;text-align:right}
            #content {background:#FFFFFF}
            .created, .modified {color:#999;margin-left:10px;font-size:small;font-style:italic;padding-bottom:0.5em}
            .modified {margin:0px}
            .tags{margin-left:10px;text-transform:uppercase;}
            .text {padding:2em;}
            .text h1.title {font-size:2.5em}
            .more {margin-left:10px}
            #pager {text-align:center;padding:2em}
            #pager span.notactive {color:#ccc}
            #subfooter {padding:2em;border-top:#000000 1px solid}
            #footer{width:65%;margin:auto;font-size:80%;text-align:center;padding:2em 0em 2em 0em;border-top:#000000 1px solid;height:2em;}
            .push {height:6em}
        </style>
% }
        <link rel="alternate" type="application/rss+xml" title="<%= $config->{title} %>" href="<%= $self->url_for('index', format => 'rss') %>" />
    </head>
    <body>
        <div id="body">
            <div id="header">
                <h1 id="title"><a href="<%= $self->url_for('root', format => '') %>"><%= $config->{title} %></a>
                <sup><a href="<%= $self->url_for('index', format=>'rss') %>"><img src="data:image/png;base64,
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJ
bWFnZVJlYWR5ccllPAAAAlJJREFUeNqkU0toU0EUPfPJtOZDm9gSPzWVKloXgiCCInXTRTZVQcSN
LtyF6qILFwoVV+7EjR9oFy7VlSAVF+ouqMWWqCCIrbYSosaARNGmSV7ee+OdyUsMogtx4HBn5t1z
7twz85jWGv8zZHaUmRjlHBnBkRYSCSnog/wzuECZMzxgDNPEW5E0ASHTl4qf6h+KD6iwUpwyuRCw
kcCCNSPoRsNZKeS31D8WTOHLkqoagbQhV+sV1fDqEJQoidSCCMiMjskZU9HU4AAJpJsC0gokTGVD
XnfhA0DRL7+Hn38M/foOeOUzOJEZs+2Cqy5F1iXs3PZLYEGl+ux1NF7eAmpfIXedQOjYbYgdh9tk
Y3oTsDAnNCewPZqF8/SKjdqs+7aCj5wFDkwSlUEvzFgyPK8twNvuBv3GzixgzfgcQmNXqW/68IgE
is+BvRPQ0fXE9eC7Lvy/Cfi5G8DSQ7DkTrCxKbrgJPSTS5TUDQwfgWvIBO0Dvv+bgPFAz12Dzl4E
7p5svpQ9p6HLy9DFF2CD+9sCHpG9DgHHeGAExDglZnLAj09APgts2N089pdFsPjmXwIuHAJk8JKL
rXtuDWtWtQwWiliScFapQJedKxKsVFA0KezVUeMvprcfHDkua6uRzqsylQ2hE2ZPqXAld+/tTfIg
I56VgNG1SDkuhmIb+3tELCLRTYYpRdVDFpwgCJL2fJfXFufLS4Xl6v3z7zBvXkdqUxjJc8M4tC2C
fdDoNe62XPaCaOEBVOjbm++YnSphpuSiZAR6CFQS4h//ZJJD7acAAwCdOg/D5ZiZiQAAAABJRU5E
rkJggg==" alt="RSS" /></a></sup>

                </h1>
                <h2 id="descr"><%= $config->{descr} %></h2>
                <span id="author"><%= $config->{author} %></span>, <span id="about"><%= $config->{about} %></span>
                <div id="menu">
% for (my $i = 0; $i < @{$config->{menu}}; $i += 2) {
                    <a href="<%= $config->{menu}->[$i + 1] %>"><%= $config->{menu}->[$i] %></a>
% }
                </div>
            </div>
            <div id="content">
            <%= $self->render_inner %>
            </div>
            <div class="push"></div>
        </div>
        <div id="footer"><%= $config->{footer} %></div>
% foreach my $file (@{$config->{js}}) {
        <script type="text/javascript" href="/<%= $file %>" />
% }
    </body>
</html>

__END__

=head1 NAME

Bootylicious -- one-file blog on Mojo steroids!

=head1 SYNOPSIS

    $ perl bootylicious.pl daemon

=head1 DESCRIPTION

Bootylicious is a minimalistic blogging application built on
L<Mojolicious::Lite>. You start with just one file, but it is easily extendable
when you add new templates, css files etc.

=head1 CONFIGURATION

Bootylicious can be configured through config file that is placed in the same
directory as bootylicious.pl file and is called bootylicious.conf. It is in JSON
format.

    {
        "title" : "my blog title",
        "descr" : "my blog description",
        "author" : "myname",
        "menu" : [
            "item1", "link1",
            "item2", "link2",
            ...
        ],
        ...
    }

If you are using Bootylicious' default templates, there are a number of
configuration options you can set to customize them without ever having to
touch html or template files:

=over 4

=item * author - set the blog author's name. Can also be set via the
BOOTYLICIOUS_AUTHOR environment variable. Default value is "whoami".

=item * about - set the blog author's short description. Can also be set
via the BOOTYLICIOUS_ABOUT environment valiable. Default value is
"Perl hacker".

=item * email - set the blog author's email. Can also be set via the
BOOTYLICIOUS_EMAIL environment variable. Default value is "" (empty).

=item * title - set the blog title. Can also be set via the BOOTYLICIOUS_TITLE
environment variable. Default value is "Just another blog".

=item * descr - set the blog's short description (subtitle). Can also be set
via the BOOTYLICIOUS_DESCR environment variable. Default value is "I do not
know if I need this".

=item * menu - set the blog's menu content. Value should be an array, because
the order matters

        "menu" : [
            "item1", "link1",
            "item2", "link2",
            ...
        ],

=item * css - loads given css filename from BOOTYLICIOUS_PUBLICDIR/ (see below)
and uses it instead of standard bootylicious css. To load more than one css
file, in the same given order, just pass an array (e.g.:
"css" : [ "foo.css", "bar.css", "baz.css" ]).

=item * js - loads given javascript filename from BOOTYLICIOUS_PUBLICDIR/ (see
below) and uses it on the templates. To load more than one js file, in the same
given order, just pass an array (e.g.: "js" : [ "foo.js", "bar.js", "baz.js" ]).

=item * theme - bootylicious can automatically import css and js files via
themes. Just put those files under PUBLICDIR/themes/my-theme/ and set this
option to "my-theme". Files are loaded in the same order as the filesystem
gives them, usually alphabetic.

=item * footer - sets each page's footer text, to appear in every page.

=back

Also, the following options can be set to change the way bootylicious behaves:

=over 4

=item * articlesdir - set the dir where articles should be fetched from
Can also be set via the BOOTYLICIOUS_ARTICLESDIR environment variable
Default value is "articles".

=item * publicdir - set the dir where bootylicious looks for static objects,
like images, css/js files, etc. Can also be set via the BOOTYLICIOUS_PUBLICDIR
environment variable. Default value is "public".

=item * templatesdir - set the dir where bootylicious looks for template files,
in case you want to override the default ones. Can also be set via the 
BOOTYLICIOUS_TEMPLATESDIR environment variable. Default value is "templates".

=item * cuttag - set the cuttag for parsing the articles. Default is "cut".

=item * perl5lib - set any additional lib folders the script should look 
into before trying to load Perl 5 modules (ideal for integrating with 
L<< local::lib >> and use inside shared hosting environments)

=back

=head1 FILESYSTEM

All the articles must be stored in BOOTYLICIOUS_ARTICLESDIR directory 
("articles", by default) with a name like 20090730-my-new-article.pod. 
They are parsed with L<< Pod::Simple::HTML >>.

The Pod filename format must comply with either of the following:

=over 4

=item * YYYYMMDD-title.pod

=item * YYYYMMDDTHH:MM:SS-title.pod

=back

The title may contain dots (".") or dashes ("-") freely.

=head1 TEMPLATES

Embedded templates will work just fine, but when you want to have something more
advanced just create a template in templates/ directory with the same name but
optionally with a different extension.

For example there is index.html.epl, thus templates/index.html.epl should be
created with a new content. If you want to use a different base directory for the 
templates, set the C<templatesdir> config option as explained above.

=head1 DEVELOPMENT

=head2 Repository

    http://github.com/vti/bootylicious/commits/master

=head1 SEE ALSO

L<Mojo> L<Mojolicious> L<Mojolicious::Lite>

=head1 CREDITS

Breno G. de Oliveira

Konstantin Kapitanov

Sebastian Riedel

=head1 AUTHOR

Viacheslav Tykhanovskyi, C<vti@cpan.org>.

=head1 COPYRIGHT

Copyright (C) 2008-2009, Viacheslav Tykhanovskyi.

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl 5.10.

=cut
