package Bootylicious::CommentIteratorLoader;

use strict;
use warnings;

use base 'Bootylicious::FileIteratorLoader';

__PACKAGE__->attr(filter => sub {qr/\.comment-(\d+)$/});
__PACKAGE__->attr(element_class => 'Bootylicious::Comment');

1;
