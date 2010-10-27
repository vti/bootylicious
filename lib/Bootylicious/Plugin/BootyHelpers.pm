package Bootylicious::Plugin::BootyHelpers;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Mojo::ByteStream 'b';

sub register {
    my ($self, $app) = @_;

    my $config = $app->config;

    $app->helper(
        render_smart => sub {
            my $self = shift;

            $app->plugins->run_hook(before_render => $self);

            $self->render(@_) unless $self->res->code;
        }
    );

    $app->helper(
        render_article_or_preview => sub {
            my $self    = shift;
            my $article = shift;

            my $parser = $self->parsers->{$article->format};
            $parser ||= sub { $_[0] };

            my $cuttag = quotemeta $self->config->{cuttag};

            my $content = $article->content;

            my ($preview, $preview_link);
            if ($content =~ s{^(.*?)\n$cuttag(?: (.*?))?(?:\n|\r|\n\r)}{}s) {
                $preview      = $1;
                $preview_link = $2 || $self->config->{cuttext};
                $content      = $3;
            }

            return Mojo::ByteStream->new(
                $parser->($preview) . $self->tag(
                    div => class => 'more' => sub {
                        '&rarr; '
                          . $self->link_to_full_content($article,
                            $preview_link);
                    }
                )
            ) if $preview;

            return Mojo::ByteStream->new($parser->($content));
        }
    );

    $app->helper(
        render_article => sub {
            my $self    = shift;
            my $article = shift;

            my $parser = $self->parsers->{$article->format};
            $parser ||= sub { $_[0] };

            my $cuttag = quotemeta $self->config->{cuttag};

            my $head = $article->content;
            my $tail = '';
            if ($head =~ s{(.*?)\n$cuttag.*?\n(.*)}{$1}s) {
                $tail = $2;
            }

            my $cuttag_anchor = '<a name="cut"></a>';

            my $string;
            $string = $parser->($head);
            $string .= $cuttag_anchor . $parser->($tail) if $tail;

            return Mojo::ByteStream->new($string);
        }
    );

    $app->helper(
        article_author => sub {
            my $self    = shift;
            my $article = shift;

            return $article->author || $config->{author};
        }
    );

    $app->helper(
        comment_author => sub {
            my $self    = shift;
            my $comment = shift;

            return $comment->author unless $comment->url;

            return $self->link_to($comment->url => sub { $comment->author });
        }
    );

    $app->helper(
        date => sub {
            my $self = shift;
            my $date = shift;
            my $fmt  = shift;

            return '' unless $date;

            $fmt ||= $config->{'datefmt'};

            return b($date->strftime($fmt))->decode('utf-8');
        }
    );
    $app->helper(date_rss => sub { Mojo::Date->new($_[1]->epoch)->to_string }
    );
    $app->helper(
        href_to_article => sub {
            my $self    = shift;
            my $article = shift;

            return $self->url_for(
                article => (
                    year   => $article->created->year,
                    month  => $article->created->month,
                    alias  => $article->name,
                    format => 'html'
                )
            );
        }
    );
    $app->helper(
        link_to_article => sub {
            my $self    = shift;
            my $article = shift;

            my $href = $self->href_to_article($article);

            my $cb = ref $_[-1] eq 'CODE' ? pop : undef;

            if ($article->link) {
                my $string = '';

                $string
                  .= $self->link_to($href => $cb || sub { $article->title });
                $string .= '&nbsp;';
                $string .= $self->link_to($article->link => sub {"&raquo;"});

                return Mojo::ByteStream->new($string);
            }

            return $self->link_to($href => $cb || sub { $article->title });
        }
    );
    $app->helper(
        link_to_full_content => sub {
            my $self = shift;
            my ($article, $preview_link) = @_;

            my $href = $self->href_to_article($article);
            $href->fragment('cut');

            return $self->link_to($href => sub {$preview_link});
        }
    );
    $app->helper(
        link_to_tag => sub {
            my $self = shift;
            my $tag  = shift;

            my $name = ref $tag ? $tag->name : $tag;

            my $cb = ref $_[-1] eq 'CODE' ? $_[-1] : sub {$name};
            my $args = ref $_[0] eq 'HASH' ? $_[0] : {};

            return $self->link_to(
                tag => {tag => $name, format => 'html', %$args} => $cb);
        }
    );
    $app->helper(
        tags_links => sub {
            my $self    = shift;
            my $article = shift;

            my @links = map { $self->link_to_tag($_) } @{$article->tags};

            my $string = '';
            $string .= join ', ' => @links;

            return Mojo::ByteStream->new($string);
        }
    );
    $app->helper(
        link_to_page => sub {
            my $self = shift;
            my $name = shift;

            my %args = ref $_[0] eq 'HASH' ? %{shift @_} : ();

            my $timestamp = shift;

            my $query = delete $args{query} || {};

            if ($timestamp) {
                return $self->link_to(
                    $self->url_for($name, %args, format => 'html')
                      ->query(timestamp => $timestamp, %$query) => @_);
            }
            else {
                return $self->tag('span' => @_);
            }
        }
    );
    $app->helper(
        link_to_author => sub {
            my $self   = shift;
            my $author = shift;

            return $author || $self->config('author');
        }
    );

    $app->helper(
        permalink_to => sub {
            my $self = shift;
            my $link = shift;

            return $self->link_to($link => sub {'&#x2605;'});
        }
    );

    $app->helper(
        strings => sub {
            my $self = shift;

            my $string = $config->{'strings'}->{$_[0]};

            for (my $i = 0; $i < @_; $i++) {
                $string =~ s/\[_$i\]/$_[$i]/;
            }

            return $string;
        }
    );

    foreach my $name (qw/articles pages drafts/) {
        my $option = $config->{"${name}_directory"} || '';
        $app->helper(
            "${name}_root" => sub {
                ($option =~ m/^\//) ? $option : $app->home->rel_dir($option);
            }
        );
    }

    $app->helper(page_limit => sub { $config->{pagelimit} });

    $app->helper(
        meta => sub {
            my $self = shift;

            my $string = '';

            if (my $description = $self->stash('description')) {
                $string .= $self->tag(
                    'meta',
                    name    => 'description',
                    content => $description
                );
            }

            my $meta_from_config = $self->config('meta');
            $meta_from_config = [$meta_from_config]
              unless ref $meta_from_config eq 'ARRAY';

            foreach my $meta (@$meta_from_config) {
                $string .= $self->tag('meta' => %$meta);
            }

            return Mojo::ByteStream->new($string);
        }
    );

    $app->helper(
        href_to_rss => sub {
            my $self = shift;

            return $self->url_for('index', format => 'rss')->to_abs;
        }
    );

    $app->helper(
        link_to_rss => sub {
            my $self = shift;

            return $self->link_to($self->href_to_rss => @_);
        }
    );

    $app->helper(
        href_to_comments_rss => sub {
            my $self = shift;

            return $self->url_for('comments', format => 'rss')->to_abs;
        }
    );

    $app->helper(
        link_to_comments_rss => sub {
            my $self = shift;

            return $self->link_to($self->href_to_comments_rss => @_);
        }
    );

    $app->helper(
        menu => sub {
            my $self = shift;

            my @links;

            my $menu = $self->config('menu');

            for (my $i = 0; $i < @$menu; $i += 2) {
                my $title = $menu->[$i];
                my $href  = $menu->[$i + 1];

                push @links, $self->link_to($href => sub {$title});
            }

            return Mojo::ByteStream->new(join ' ' => @links);
        }
    );

    $app->helper(
        link_to_home => sub {
            my $self = shift;

            return $self->link_to(
                'root' => {format => undef},
                title  => $self->config('title'),
                rel => 'home' => sub { $self->config('title') }
            );
        }
    );

    $app->helper(
        link_to_bootylicious => sub {
            my $self = shift;

            return $self->link_to('http://getbootylicious.org' => title =>
                  'Powered by Bootylicious!' => sub {'Bootylicious'});
        }
    );

    $app->helper(
        powered_by => sub {
            my $self = shift;

            return $self->link_to('http://getbootylicious.org' =>
                  sub {'Powered by Bootylicious'});

        }
    );

    $app->helper(
        generator => sub {
            my $self = shift;

            return Mojo::ByteStream->new('Bootylicious ' . $main::VERSION);
        }
    );

    $app->helper(
        link_to_archive => sub {
            my $self = shift;
            my ($year, $month) = @_;

            my @months = (
                qw/January February March April May July June August September October November December/
            );
            my $title = $months[$month - 1] . ' ' . $year;
            return $self->link_to(
                'articles',
                {   year  => $year,
                    month => $month
                } => sub {$title}
            );
        }
    );

    $app->helper(
        gravatar => sub {
            my $self  = shift;
            my $email = shift;

            my %attrs = (
                class  => 'gravatar',
                width  => 40,
                height => 40
            );

            return $self->tag(
                'img',
                src =>
                  'http://www.gravatar.com/avatar/00000000000000000000000000000000?s=40',
                %attrs
            ) unless $email;

            $email = lc $email;
            $email =~ s/^\s+//;
            $email =~ s/\s+$//;

            my $hash = Mojo::ByteStream->new($email)->md5_sum;

            my $url = "http://www.gravatar.com/avatar/$hash?s=40";

            return $self->tag(
                'img',
                src => $url,
                %attrs,
                @_
            );
        }
    );

    $app->helper(
        href_to_comments => sub {
            my $self    = shift;
            my $article = shift;

            return $self->href_to_article($article)->fragment('comments');
        }
    );

    $app->helper(
        href_to_comment => sub {
            my $self    = shift;
            my $comment = shift;

            return $self->href_to_article($comment->article)
              ->fragment('comment-' . $comment->number);
        }
    );

    $app->helper(
        link_to_comment => sub {
            my $self    = shift;
            my $comment = shift;

            return $self->link_to($self->href_to_comment($comment) =>
                  sub { $comment->article->title });
        }
    );

    $app->helper(
        link_to_comments => sub {
            my $self    = shift;
            my $article = shift;

            my $href = $self->href_to_article($article);

            return $self->link_to(
                $href->fragment('comment-form') => sub {'No comments'})
              unless $article->comments->size;

            return $self->link_to($href->fragment('comments') =>
                  sub { 'Comments (' . $article->comments->size . ') '; });
        }
    );

    $app->helper(
        comments_enabled => sub {
            shift->config('comments_enabled') ? 1 : 0;
        }
    );
}

1;
