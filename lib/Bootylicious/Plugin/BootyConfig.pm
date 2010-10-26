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
    $app->plugin(
        validator => {
            messages => {
                REQUIRED                => 'Required',
                EMAIL_CONSTRAINT_FAILED => "Doesn't look like an email to me",
                URL_CONSTRAINT_FAILED   => "Doesn't look like an url to me"
            }
        }
    );
    $app->plugin('bot_protection');

    $conf->{default} = $self->_default unless exists $conf->{default};
    my $config = $app->plugin('json_config' => $conf);

    $app->secret($conf->{secret});

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
    $app->renderer->root($app->home->rel_dir($config->{templates_directory}))
      if defined $config->{templates_directory};

    # set proper public base dir, if defined
    $app->static->root($app->home->rel_dir($config->{public_directory}))
      if defined $config->{public_directory};

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

    $app->plugin('booty_helpers');

    $c->add_parser(
        pod => sub { $app->renderer->helper->{pod_to_html}->(undef, @_) });

    if (my $theme = $config->{theme}) {
        my $theme_class = join '::' => 'Bootylicious::Theme',
          Mojo::ByteStream->new($theme)->camelize;

        $app->renderer->default_template_class($theme_class);
        $app->static->default_static_class($theme_class);

        $app->plugin($theme_class);
    }

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

    foreach my $plugin (@plugins) {
        $app->plugin($plugin->{name} => $plugin->{args});
    }
}

sub _default {
    {   author      => 'whoami',
        email       => '',
        title       => 'Just another blog',
        about       => 'Perl hacker',
        description => 'I do not know if I need this',

        cuttag    => '[cut]',
        cuttext   => 'Keep reading',
        pagelimit => 10,
        datefmt   => '%a, %d %b %Y',

        menu => [
            index   => '/',
            tags    => '/tags.html',
            archive => '/articles.html'
        ],
        footer =>
          'Powered by <a href="http://getbootylicious.org">Bootylicious</a>',
        theme => '',

        comments_enabled => 1,

        meta => [],
        css  => [],
        js   => [],

        strings => {
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

        perl5lib => '',
        loglevel => 'error',

        articles_directory  => 'articles',
        pages_directory     => 'pages',
        drafts_directory    => 'drafts',
        public_directory    => 'public',
        templates_directory => 'templates',
    };
}

1;
