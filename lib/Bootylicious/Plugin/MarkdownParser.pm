package Bootylicious::Plugin::MarkdownParser;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

use constant MARKDOWN => eval { require Text::Markdown; 1 };

sub register {
    my ($self, $app) = @_;

    return unless MARKDOWN;

    $app->renderer->helpers->{add_parser}
      ->(undef, md => sub { Text::Markdown->new->markdown($_[0]) });
}

1;
