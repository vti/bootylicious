package Bootylicious::CommentIteratorLoader;

use strict;
use warnings;

use base 'Bootylicious::FileIteratorLoader';

__PACKAGE__->attr(filter => sub {qr/\.comment-(\d+)$/});
__PACKAGE__->attr(element_class => 'Bootylicious::Comment');

sub load {
    my $iterator = shift->SUPER::load(@_);

    $iterator->elements(
        [   sort { $a->created->epoch <=> $b->created->epoch }
              @{$iterator->elements}
        ]
    );
    $iterator->rewind;

    return $iterator;
}

1;
