package Bootylicious::ArticleContentLoader;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('path');
__PACKAGE__->attr('ext');
__PACKAGE__->attr('parsers' => sub { {} });
__PACKAGE__->attr('cuttext');
__PACKAGE__->attr('cuttag');

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

    my ($head, $tail, $preview_link_text) = $self->_parse_cuttag(\$string);

    $head = $parser->($head);
    return {} unless $head;

    $tail = $parser->($tail) if $tail;

    my ($preview, $content);

    if ($tail) {
        $content = $head . '<a name="cut"></a>' . $tail;
        $preview = $head;
    }
    else {
        $content = $head;
        $preview = '';
    }

    return {
        preview      => $preview,
        preview_link => $preview_link_text,
        content      => $content
    };
}

sub _parse_cuttag {
    my $self   = shift;
    my $string = shift;

    my $cuttag = $self->cuttag;

    my $tail              = '';
    my $preview_link_text = '';
    if ($$string =~ s{(.*?)\Q$cuttag\E(?: (.*?))?(?:\n|\r|\n\r)(.*)}{$1}s) {
        $tail = $3;
        $preview_link_text = $2 || $self->cuttext;
    }

    return ($$string, $tail, $preview_link_text);
}

1;
