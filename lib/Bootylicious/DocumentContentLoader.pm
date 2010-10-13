package Bootylicious::DocumentContentLoader;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('path');
__PACKAGE__->attr('ext');
__PACKAGE__->attr('parsers' => sub { {} });

sub load {
    my $self = shift;

    my $path = $self->path;

    my $parser = $self->parsers->{$self->ext};
    unless ($parser) {
        warn 'No parser found';
        return {};
    }

    open my $fh, '<:encoding(UTF-8)', $path or return {};
    while (my $line = <$fh>) {
        last if $line eq '';
        last if $line !~ m/^(.*?): /;
    }

    my $string = '';
    while (my $line = <$fh>) {
        $string .= $line;
    }

    my $content = $parser->($string);
    return {} unless $content;

    return {content => $content};
}

1;
