package Bootylicious::ArticleIteratorLoader;

use strict;
use warnings;

use base 'Bootylicious::FileIteratorLoader';

__PACKAGE__->attr(filter => sub {qr/^[^\.]+\.[^\.]+$/});
__PACKAGE__->attr(element_class => 'Bootylicious::Article');

1;
