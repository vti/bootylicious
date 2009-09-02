package Bootylicious::Parser::Mmd;

use strict;
use warnings;

use base 'Mojo::Base';

use Text::MultiMarkdown;

__PACKAGE__->attr(
    md =>
      sub { Text::MultiMarkdown->new(use_metadata => 1, strip_metadata => 1) }
);

sub parser_cb {
    my $self = shift;

    return sub {
        my ($head_string, $tail_string) = @_;

        my $title = '';
        my $link  = '';
        my $tags  = [];
        my $head  = '';
        my $tail  = '';

        $head = $self->md->markdown($head_string);

        $title = $self->md->{_metadata}->{Title};
        $link = $self->md->{_metadata}->{Link};
        @$tags =
          map { s/^\s+//; s/\s+$//; $_ }
          split(/,/, $self->md->{_metadata}->{Tags});

        if ($tail_string) {
            $tail = $self->md->markdown($tail_string);
        }

        return {
            title => $title,
            link  => $link,
            tags  => $tags,
            head  => $head,
            tail  => $tail
        };
      }
}

1;
