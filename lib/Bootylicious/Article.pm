package Bootylicious::Article;

use strict;
use warnings;

use base 'Bootylicious::Document';

use Bootylicious::ArticleContentLoader;

__PACKAGE__->attr([qw/cuttag cuttext/]);

__PACKAGE__->attr(
    content_loader => sub {
        Bootylicious::ArticleContentLoader->new(
            path    => $_[0]->path,
            parsers => $_[0]->parsers,
            ext     => $_[0]->ext,
            cuttext => $_[0]->cuttext,
            cuttag  => $_[0]->cuttag
        );
    }
);

sub preview      { shift->_content(preview      => @_) }
sub preview_link { shift->_content(preview_link => @_) }

1;
