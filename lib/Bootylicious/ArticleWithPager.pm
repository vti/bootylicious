package Bootylicious::ArticleWithPager;

use strict;
use warnings;

use base 'Bootylicious::Decorator';

__PACKAGE__->attr('prev');
__PACKAGE__->attr('next');

1;
