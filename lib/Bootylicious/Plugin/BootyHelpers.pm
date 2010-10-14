package Bootylicious::Plugin::BootyHelpers;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use Mojo::ByteStream 'b';

sub register {
    my ($self, $app) = @_;

    my $config = $app->renderer->helper->{config}->();

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
        date => sub {
            my $self = shift;
            my $date = shift;
            my $fmt  = shift;

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

            if ($article->link) {
                my $string = '';

                $string .= $self->link_to($href => sub { $article->title });
                $string .= '&nbsp;';
                $string .= $self->link_to($article->link => sub {"&raquo;"});

                return Mojo::ByteStream->new($string);
            }

            return $self->link_to($href => sub { $article->title });
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

            my $cb = ref $_[-1] eq 'CODE' ? $_[-1] : sub {$tag};
            my $args = ref $_[0] eq 'HASH' ? $_[0] : {};

            return $self->link_to(
                tag => {tag => $tag, format => 'html', %$args} => $cb);
        }
    );
    $app->helper(
        tags_links => sub {
            my $self    = shift;
            my $article = shift;

            my @links = map { $self->link_to_tag($_) } @{$article->tags};

            my $string = '<div class="tags">';
            $string .= join ', ' => @links;
            $string .= '</div>';

            return Mojo::ByteStream->new($string);
        }
    );
    $app->helper(
        link_to_page => sub {
            my $self      = shift;
            my $name      = shift;
            my $timestamp = shift;

            my %args = ref $_[0] eq 'HASH' ? %{shift @_} : ();

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
        my $option = $config->{"${name}dir"};
        $app->helper(
            "${name}_root" => sub {
                ($option =~ m/^\//) ? $option : $app->home->rel_dir($option);
            }
        );
    }

    $app->helper(page_limit => sub { $config->{pagelimit} });
}

1;
