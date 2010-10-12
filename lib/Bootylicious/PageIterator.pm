package Bootylicious::PageIterator;

use strict;
use warnings;

use base 'Bootylicious::DocumentIterator';

use Bootylicious::Page;

sub create_element { shift; Bootylicious::Page->new(@_) }

1;
