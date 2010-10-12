package Bootylicious::DraftIterator;

use strict;
use warnings;

use base 'Bootylicious::DocumentIterator';

use Bootylicious::Draft;

sub create_element { shift; Bootylicious::Draft->new(@_) }

1;
