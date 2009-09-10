package Bootylicious::Parser::Md;

use strict;
use warnings;

use base 'Mojo::Base';

use Text::Markdown;

__PACKAGE__->attr(md => sub { Text::Markdown->new });

sub parser_cb {
    my $self = shift;

    return sub {
        my ($head_string, $tail_string) = @_;

        my $head  = '';
        my $tail  = '';

        $head = $self->md->markdown($head_string);

        if ($tail_string) {
            $tail = $self->md->markdown($tail_string);
        }

        return {
            head  => $head,
            tail  => $tail
        };
      }
}

1;
