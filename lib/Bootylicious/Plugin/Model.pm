package Bootylicious::Plugin::Model;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Mojolicious::Controller;

use Bootylicious::Article;
use Bootylicious::ArticleArchive;
use Bootylicious::ArticleByTagIterator;
use Bootylicious::ArticleByQueryIterator;
use Bootylicious::ArticleIterator;
use Bootylicious::ArticleIteratorFinder;
use Bootylicious::ArticlePager;
use Bootylicious::Draft;
use Bootylicious::IteratorSearchable;
use Bootylicious::Page;
use Bootylicious::PageIterator;
use Bootylicious::PageIteratorFinder;
use Bootylicious::TagCloud;

sub register {
    my ($self, $app) = @_;

    my $c = Mojolicious::Controller->new(app => $app);

    my $config  = $c->config;
    my $parsers = $c->parsers;

    my $articles_root = $c->articles_root;
    my $pages_root    = $c->pages_root;
    my $drafts_root   = $c->drafts_root;

    my $page_limit = $config->{pagelimit};

    $app->helper(
        get_pager => sub {
            shift;
            my $iterator = shift;
            Bootylicious::ArticlePager->new(
                limit    => $page_limit,
                iterator => $iterator,
                @_
            );
        }
    );

    $app->helper(
        get_articles => sub {
            shift;
            Bootylicious::ArticlePager->new(
                iterator => Bootylicious::ArticleIterator->new(
                    root => $articles_root,
                    args => {
                        cuttag  => $config->{cuttag},
                        cuttext => $config->{cuttext},
                        parsers => $parsers
                    }
                ),
                limit => $page_limit,
                @_
            );
        }
    );

    $app->helper(
        get_archive => sub {
            Bootylicious::ArticleArchive->new(
                articles => Bootylicious::ArticleIterator->new(
                    root => $articles_root,
                    args => {
                        cuttag  => $config->{cuttag},
                        cuttext => $config->{cuttext},
                        parsers => $parsers
                    }
                )
            );
        }
    );

    $app->helper(
        get_articles_by_tag => sub {
            my $self = shift;
            my $tag  = shift;

            Bootylicious::ArticlePager->new(
                iterator => Bootylicious::ArticleByTagIterator->new(
                    Bootylicious::ArticleIterator->new(
                        root => $articles_root,
                        args => {
                            cuttag  => $config->{cuttag},
                            cuttext => $config->{cuttext},
                            parsers => $parsers
                        }
                    ),
                    tag => $tag
                ),
                limit => $page_limit,
                @_
            );
        }
    );

    $app->helper(
        get_articles_by_query => sub {
            my $self  = shift;
            my $query = shift;

            return Bootylicious::ArticleByQueryIterator->new(
                Bootylicious::ArticleIterator->new(
                    root => $articles_root,
                    args => {
                        cuttag  => $config->{cuttag},
                        cuttext => $config->{cuttext},
                        parsers => $parsers
                    }
                ),
                query => $query
            );
        }
    );

    $app->helper(
        get_tag_cloud => sub {
            Bootylicious::TagCloud->new(articles =>
                  Bootylicious::ArticleIterator->new(root => $articles_root));
        }
    );

    $app->helper(
        get_article => sub {
            my $self = shift;
            Bootylicious::ArticleIteratorFinder->new(
                iterator => Bootylicious::ArticleIterator->new(
                    root => $articles_root,
                    args => {
                        cuttag  => $config->{cuttag},
                        cuttext => $config->{cuttext},
                        parsers => $parsers
                    }
                )
            )->find(@_);
        }
    );

    $app->helper(
        get_page => sub {
            my $self = shift;
            my $name = shift;
            Bootylicious::PageIteratorFinder->new(
                iterator => Bootylicious::PageIterator->new(
                    root => $pages_root,
                    args => {
                        cuttag  => $config->{cuttag},
                        cuttext => $config->{cuttext},
                        parsers => $parsers
                    }
                )
            )->find($name);
        }
    );

    $app->helper(
        get_draft => sub {
            my $self = shift;
            my $name = shift;

            Bootylicious::DraftIteratorFinder->new(
                iterator => Bootylicious::DraftIterator->new(
                    root => $self->drafts_root,
                    args => {
                        cuttag  => $config->{cuttag},
                        cuttext => $config->{cuttext},
                        parsers => $parsers
                    }
                ),
                name => $name
            );
        }
    );
}

1;
