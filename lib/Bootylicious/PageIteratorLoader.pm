package Bootylicious::PageIteratorLoader;

use strict;
use warnings;

use base 'Bootylicious::FileIteratorLoader';

__PACKAGE__->attr(filter => sub {qr/^[^\/\.]+\.[^\.]+$/});
__PACKAGE__->attr(element_class => 'Bootylicious::Page');

1;
