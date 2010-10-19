package Bootylicious::FileIteratorLoader;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('element_class');
__PACKAGE__->attr('filter');
__PACKAGE__->attr('root');
__PACKAGE__->attr('path');

use Mojo::ByteStream;
use Mojo::Loader;
use Bootylicious::Iterator;

sub files {
    my $self = shift;

    my $root = $self->root;
    my $path = $self->path;

    return glob $root ? "$root/*" : "$path*";
}

sub create_element {
    my $self = shift;

    Mojo::Loader->new->load($self->element_class);

    return $self->element_class->new;
}

sub load {
    my $self     = shift;
    my $iterator = shift;

    $iterator ||= Bootylicious::Iterator->new;

    my $filter = $self->filter;

    my @elements = ();
    foreach my $file ($self->files) {
        $file = Mojo::ByteStream->new($file)->decode('UTF-8')->to_string;

        my $basename = File::Basename::basename($file);
        next if $filter && $basename !~ m/$filter/;

        my $element = $self->create_element;
        $element->load($file);

        push @elements, $element;
    }

    $iterator->elements(
        [sort { $b->created->epoch <=> $a->created->epoch } @elements]);
    $iterator->rewind;

    return $iterator;
}

1;
