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
            my ($article) = @_;

            my $href = $self->href_to_article($article);
            $href->fragment('cut');

            return $self->link_to($href => sub { $article->preview_link });
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
            my $timestamp = shift;

            return $self->link_to(
                'index' => {timestamp => $timestamp, format => 'html'} => @_);
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
