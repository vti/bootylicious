package Bootylicious::DraftIteratorLoader;

use strict;
use warnings;

use base 'Bootylicious::ArticleIteratorLoader';

__PACKAGE__->attr(element_class => 'Bootylicious::Draft');

1;
