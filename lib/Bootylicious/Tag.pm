package Bootylicious::Tag;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr([qw/name count created modified/]);

1;
