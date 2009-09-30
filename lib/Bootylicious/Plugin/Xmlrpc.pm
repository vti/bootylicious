package Bootylicious::Plugin::Xmlrpc;

use strict;
use warnings;

use base 'Mojo::Base';

use Protocol::XMLRPC::Dispatcher;
use Protocol::XMLRPC::MethodResponse;

__PACKAGE__->attr([qw/username password/]);
__PACKAGE__->attr('ctx');

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);

    if (!defined $self->username || !defined $self->password) {
        die 'Username and password are required';
    }

    return $self;
}

sub hook_init {
    my $self = shift;
    my $app = shift;

    my $dispatcher = $self->_dispatcher($app);

    my $r = $app->routes;

    $r->route('/xmlrpc')->via('POST')->to(
        callback => sub {
            my $c = shift;

            $self->ctx($c);

            $dispatcher->dispatch(
                $c->req->body => sub {
                    my $method_response = shift;

                    $c->stash(rendered => 1);
                    $c->res->code(200);
                    $c->res->headers->content_type('text/xml');

                    $c->res->body($method_response->to_string);
                }
            );
        }
    );
}

sub _dispatcher {
    my $self = shift;
    my ($app) = @_;

    return Protocol::XMLRPC::Dispatcher->new(
        methods => {
            'blogger.getUsersBlogs' => {
                ret => 'array',
                args => [qw/string string string/],
                handler => sub {
                    my ($api_key, $username, $password) = @_;

                    $self->_check_access($username, $password);

                    my $config = main::config();

                    return [
                        {   url      => $self->ctx->req->url->host,
                            blogid   => 'bootylicious',
                            blogName => $config->{title} || ''
                        }
                    ];
                }
            },
            'metaWeblog.getCategories' => {
                ret => 'struct',
                args => [qw/string string string/],
                handler => sub {
                    my @params = @_;
                    my ($blogid, $username, $password) = @_;

                    $self->_check_access($username, $password);

                    my $tags = main::get_tags();

                    $tags = {
                        map {
                            $_ => {
                                description => $_,
                                htmlUrl     => $self->ctx->url_for(
                                    'tag',
                                    tag    => $_,
                                    format => 'html'
                                  )->to_abs,
                                rssUrl => $self->ctx->url_for(
                                    'tag',
                                    tag    => $_,
                                    format => 'rss'
                                  )->to_abs,
                              }
                          } keys %$tags
                    };

                    return $tags;
                }
            },
            'metaWeblog.getRecentPosts' => {
                ret => 'array',
                args => [qw/string string string int/],
                handler => sub {
                    my @params = @_;
                    my ($blogid, $username, $password, $limit) = @_;

                    $self->_check_access($username, $password);

                    my ($articles) = main::get_articles(limit => $limit->value);

                    return [
                        map {
                            {   title       => $_->{title},
                                description => $_->{content},
                                content     => $_->{content},
                                categories  => $_->{tags}
                            }
                          } @$articles
                    ];
                }
            },
            'metaWeblog.newPost' => {
                ret => 'string',
                args    => [qw/string string string struct boolean/],
                handler => sub {
                    my ($blogid, $username, $password, $struct, $publish) = @_;

                    $self->_check_access($username, $password);

                    my ($year, $month);

                    my @time = localtime(time);
                    my $timestamp =
                        ($year = $time[5] + 1900)
                      . ($month = sprintf("%02d", $time[4] + 1))
                      . (sprintf("%02d", $time[3])) . 'T'
                      . sprintf("%02d", $time[2]) . ':'
                      . sprintf("%02d", $time[1]) . ':'
                      . sprintf("%02d", $time[0]);

                    my $alias = $struct->value->{title};
                    $alias = lc $alias;
                    $alias =~ s/ /-/g;

                    my $format = $struct->value->{format} || 'pod';

                    my $config = main::config();

                    my $articlesdir = $config->{articlesdir};
                    my $path = "$articlesdir/$timestamp-$alias.$format";

                    $self->_write_article($path, $struct);

                    return $year . '/' . $month . '/' . $alias;
                }
            },
            'metaWeblog.getPost' => {
                ret => 'struct',
                args    => [qw/string string string/],
                handler => sub {
                    my ($articleid, $username, $password) = @_;

                    $self->_check_access($username, $password);

                    my $article = main::get_article($articleid->value);
                    die 'Article not found' unless $article;

                    return {
                        title       => $article->{title},
                        description => $article->{content},
                        categories => $article->{tags}
                      }
                }
            },
            'metaWeblog.editPost' => {
                ret => 'boolean',
                args    => [qw/string string string struct boolean/],
                handler => sub {
                    my ($articleid, $username, $password, $struct, $publish) = @_;

                    $self->_check_access($username, $password);

                    my $article = main::get_article($articleid->value);
                    die 'Article not found' unless $article;

                    my $path = $article->{path};

                    return $self->_write_article($path, $struct)
                      ? 'true'
                      : 'false';
                }
            }
        }
    );
}

sub _check_access {
    my $self = shift;
    my ($username, $password) = @_;

    die 'Access denied'
      unless $username
          && $password
          && $self->username eq $username->value
          && $self->password eq $password->value;
}

sub _write_article {
    my $self = shift;
    my ($path, $struct) = @_;

    my $metadata = '';
    if (my $title = $struct->value->{title}) {
        $metadata .= 'Title: ' . $title . "\n";
    }

    if (my @categories = @{$struct->value->{categories} || []}) {
        $metadata .= 'Tags: ';
        $metadata .= "$_, " for @categories;
        $metadata =~ s/, $//;
        $metadata .= "\n";
    }
    $metadata .= "\n" if $metadata;

    open FILE, "> $path" or return 0;
    print FILE $metadata;
    print FILE $struct->value->{description}
      || $struct->value->{content};
    close FILE;

    return 1;
}

1;
