package Bootylicious::ArticleArchive;

use strict;
use warnings;

use base 'Mojo::Base';

use Bootylicious::ArticleArchiveYearly;
use Bootylicious::ArticleArchiveMonthly;

__PACKAGE__->attr('articles');
__PACKAGE__->attr('year');
__PACKAGE__->attr('month');

sub new {
    my $self = shift->SUPER::new(@_);

    if ($self->month) {
        return Bootylicious::ArticleArchiveMonthly->new(@_);
    }

    return Bootylicious::ArticleArchiveYearly->new(@_);
}

1;
