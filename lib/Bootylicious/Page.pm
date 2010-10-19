package Bootylicious::Page;

use strict;
use warnings;

use base 'Bootylicious::Document';

sub title { my $self = shift; $self->metadata(title => @_) || $self->name }
sub description { shift->metadata(description => @_) }

1;
