package Bootylicious::ArticleIterator;

use strict;
use warnings;

use base 'Bootylicious::DocumentIteratorWithDates';

use Bootylicious::Article;

sub create_element { shift; Bootylicious::Article->new(@_) }

1;
