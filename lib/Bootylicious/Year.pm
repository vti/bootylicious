package Bootylicious::Year;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr('year');
__PACKAGE__->attr('articles');

sub modified { shift->articles->modified }

1;
