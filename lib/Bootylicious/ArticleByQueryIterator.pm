package Bootylicious::ArticleByQueryIterator;

use strict;
use warnings;

use base 'Bootylicious::Decorator';

__PACKAGE__->attr('query');
__PACKAGE__->attr('before_context'        => 10);
__PACKAGE__->attr('after_context'         => 10);
__PACKAGE__->attr('replace_string_before' => '<font color="red">');
__PACKAGE__->attr('replace_string_after'  => '</font>');

use Mojo::ByteStream 'b';
use Bootylicious::ArticleIterator;

sub new {
    my $self = shift->SUPER::new(@_);

    return $self->build;
}

sub build {
    my $self = shift;

    my $before_context = $self->before_context;
    my $after_context  = $self->after_context;

    my $replace_string_before = $self->replace_string_before;
    my $replace_string_after  = $self->replace_string_after;

    my $q = quotemeta $self->query;

    my @articles;
    while (my $article = $self->object->next) {
        my $found = 0;

        my $title = $article->title;
        if ($title && $title
            =~ s/($q)/$replace_string_before$1$replace_string_after/isg)
        {
            $found = 1;
            $article->title($title);
        }

        my $parts   = [];
        my $content = $article->content;
        while ($content && $content
            =~ s/((?:.{$before_context})?$q(?:.{$after_context})?)//is)
        {
            my $part = $1;
            $part = b($part)->xml_escape->to_string;
            $part =~ s/($q)/$replace_string_before$1$replace_string_after/isg;
            push @$parts, $part;

            $found = 1;
        }

        $article->content($parts) if @$parts;

        push @articles, $article if $found;
    }

    return Bootylicious::ArticleIterator->new(elements => [@articles]);
}

1;
