package Bootylicious::Plugin::Model;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Mojolicious::Controller;

use Bootylicious::Article;
use Bootylicious::ArticleArchive;
use Bootylicious::ArticleArchiveSimple;
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

    my $config = $c->config;

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
                iterator =>
                  Bootylicious::ArticleIterator->new(root => $articles_root),
                limit => $page_limit,
                @_
            );
        }
    );

    $app->helper(
        get_recent_articles => sub {
            Bootylicious::ArticleIterator->new(root => $articles_root)
              ->next(5);
        }
    );

    $app->helper(
        get_archive => sub {
            shift;
            Bootylicious::ArticleArchive->new(
                articles =>
                  Bootylicious::ArticleIterator->new(root => $articles_root),
                @_
            );
        }
    );

    $app->helper(
        get_archive_simple => sub {
            Bootylicious::ArticleArchiveSimple->new(articles =>
                  Bootylicious::ArticleIterator->new(root => $articles_root),
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
                        root => $articles_root
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
                Bootylicious::ArticleIterator->new(root => $articles_root),
                query => $query);
        }
    );

    $app->helper(
        get_tag_cloud => sub {
            Bootylicious::TagCloud->new(articles =>
                  Bootylicious::ArticleIterator->new(root => $articles_root));
        }
    );

    $app->helper(
        get_tags => sub {
            Bootylicious::TagCloud->new(articles =>
                  Bootylicious::ArticleIterator->new(root => $articles_root));
        }
    );

    $app->helper(
        get_article => sub {
            my $self = shift;
            Bootylicious::ArticleIteratorFinder->new(iterator =>
                  Bootylicious::ArticleIterator->new(root => $articles_root))
              ->find(@_);
        }
    );

    $app->helper(
        get_page => sub {
            my $self = shift;
            my $name = shift;
            Bootylicious::PageIteratorFinder->new(iterator =>
                  Bootylicious::PageIterator->new(root => $pages_root))
              ->find($name);
        }
    );

    $app->helper(
        get_draft => sub {
            my $self = shift;
            my $name = shift;

            Bootylicious::DraftIteratorFinder->new(
                iterator => Bootylicious::DraftIterator->new(
                    root => $self->drafts_root
                ),
                name => $name
            );
        }
    );
}

1;
