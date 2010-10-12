package Bootylicious::Plugin::BootyConfig;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Mojolicious::Controller;

sub register {
    my ($self, $app, $conf) = @_;

    my $c = Mojolicious::Controller->new(app => $app);

    $conf ||= {};

    $app->log->level('error');

    # Default plugins
    $app->plugin('charset' => {charset => 'utf-8'});
    $app->plugin('pod_renderer');
    $app->plugin('tag_helpers');

    $conf->{default} = $self->_default;
    my $config = $app->plugin('json_config' => $conf);

    # Config access
    $app->helper(
        config => sub {
            my $self = shift;

            if (@_) {
                return $config->{$_[0]} if @_ == 1;

                $config = {%$config, @_};
            }

            return $config;
        }
    );

    # Set appropriate log level
    $app->log->level($config->{loglevel});

    # Additional Perl modules
    $self->_setup_inc($config->{perl5lib});

    # CGI hack
    $ENV{SCRIPT_NAME} = $config->{base} if defined $config->{base};

    # Don't use set locale unless it is explicitly specified via a config file
    $ENV{LC_ALL} = 'C';

    # set proper templates base dir, if defined
    $app->renderer->root($app->home->rel_dir($config->{templatesdir}))
      if defined $config->{templatesdir};

    # set proper public base dir, if defined
    $app->static->root($app->home->rel_dir($config->{publicdir}))
      if defined $config->{publicdir};

    $app->defaults(title => '', description => '', layout => 'wrapper');

    # Parser helpers
    $app->helper(parsers => sub { $config->{_parsers} });

    $app->helper(
        add_parser => sub {
            my $self = shift;
            my ($ext, $cb) = @_;

            $config->{_parsers}->{$ext} = $cb;
        }
    );

    $c->add_parser(pod => sub { $app->renderer->helper->{pod_to_html}->(undef, @_) });

    # Load additional plugins
    $self->_load_plugins($app, $config->{plugins});
}

sub _setup_inc {
    my $self     = shift;
    my $perl5lib = shift;

    return unless $perl5lib;

    push @INC, $_ for (ref $perl5lib eq 'ARRAY' ? @{$perl5lib} : $perl5lib);
}

sub _load_plugins {
    my $self = shift;
    my ($app, $plugins_arrayref) = @_;

    return unless $plugins_arrayref;
    $plugins_arrayref = [$plugins_arrayref]
      unless ref $plugins_arrayref eq 'ARRAY';

    my @plugins;

    my $prev;
    while (my $plugin = shift @{$plugins_arrayref}) {
        if (ref($plugin) eq 'HASH') {
            next unless $plugins[-1];

            $plugins[-1]->{args} = $plugin;
        }
        else {
            push @plugins, {name => $plugin, args => {}};
        }
    }

    #push @{$app->plugins->namespaces}, $_
      #for @{$config->{plugins_namespaces}};

    foreach my $plugin (@plugins) {
        $app->plugin($plugin->{name} => $plugin->{args});
    }
}

sub _default {
    {   perl5lib     => '',
        loglevel     => 'error',
        author       => 'whoami',
        email        => '',
        title        => 'Just another blog',
        about        => 'Perl hacker',
        descr        => 'I do not know if I need this',
        articlesdir  => 'articles',
        pagesdir     => 'pages',
        draftsdir    => 'drafts',
        publicdir    => 'public',
        templatesdir => 'templates',
        footer =>
          'Powered by <a href="http://getbootylicious.org">Bootylicious</a>',
        menu => [
            index   => '/',
            tags    => '/tags.html',
            archive => '/archive.html'
        ],
        theme     => '',
        cuttag    => '[cut]',
        cuttext   => 'Keep reading',
        pagelimit => 10,
        meta      => [],
        css       => [],
        js        => [],
        datefmt   => '%a, %d %b %Y',
        strings   => {
            'archive'             => 'Archive',
            'archive-description' => 'Articles index',
            'tags'                => 'Tags',
            'tags-description'    => 'Tags overview',
            'tag'                 => 'Tag',
            'tag-description'     => 'Articles with tag [_1]',
            'draft'               => 'Draft',
            'permalink-to'        => 'Permalink to',
            'later'               => 'Later',
            'earlier'             => 'Earlier',
            'not-found' => 'The page you are looking for was not found',
            'error'     => 'Internal error occuried :('
        },
        template_handler => 'ep',
    };
}

1;
