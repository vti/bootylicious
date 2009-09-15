package Bootylicious::Plugin::TocJquery;

use strict;
use warnings;

use base 'Mojo::Base';

our $VERSION = '0.02';

__PACKAGE__->attr('toc_tag' => '%TOC%');
__PACKAGE__->attr('toc_js_src' =>
      'http://samaxesjs.googlecode.com/files/jquery.toc-1.0.2.min.js');
__PACKAGE__->attr('toc_exclude' => 'h1,#descr,#title,#footer,#nottoc');

sub hook_finalize {
    my $self = shift;
    my $c    = shift;

    my $path    = $c->req->url->path;
    my $body    = $c->res->body;
    my $toc_tag = $self->toc_tag;

    #cleanup %TOC% if not article
    if ($path !~ /^\/articles/) {
        $body =~ s/$toc_tag//g;
        $c->res->body($body);
        return;
    }

    my $toc_div = $self->_toc_div;
    my $toc_js  = $self->_toc_js;
    $body =~ s/<\/[hH][eE][aA][dD]>/$toc_js <\/head>/;
    $body =~ s/$toc_tag/$toc_div/;
    $c->res->body($body);
}

sub _toc_div {
    my $self = shift;
    return q~<div id="toc"></div>~;
}

sub _toc_js {
    my $self    = shift;
    my $src     = $self->toc_js_src;
    my $exclude = $self->toc_exclude;
    return qq~
        <!-- toc_jquery -->
        <script src="$src"></script>
        <script type="text/javascript">
        \$(document).ready(function() {
            \$('#toc').toc({exclude: '$exclude'});
        });
        </script>
    ~;
}

1;

=head1 NAME

Bootylicious::Plugin::TocJquery - load TOC (Table of Contents) jQuery plugin.

=head1 DESCRIPTION

L<Bootylicious::Plugin::TocJquery> - load TOC (Table of Contents) jQuery plugin for bootylicious articles 
The TOC plugin dynamically builds a table of contents from the headings in a document and prepends legal-style section numbers to each of the headings:

    * adds numeration in front of all headings,
    * generates an HTML table of contents

=head1 SYNOPSIS

Register TocJquery and AjaxLibLoader plugins in a configuration file (bootylicious.conf), add line
like this:

    plugins=ajax_lib_Loader:jquery=on,toc_jquery:toc_tag=%TOC%     

 Insert into your post tag %TOC%, e.g.:

     =head1 NAME

    Futurama characters

    %TOC%

    Futurama is essentially a workplace sitcom whose plot revolves around the Planet Express interplanetary delivery company and its employees,
    a small group that doesn't conform to future society.

    [cut]

    =head2 Philip J. Fry 

    Fry is a dim-witted, immature, slovenly pizza delivery boy who falls into a cryogenic pod,
    causing it to activate and freeze him just after midnight on January 1, 2000, reawakening on New Year's Eve, 2999.

    =head2 Bender Bending Rodríguez 

    Bender is a heavy-drinking, cigar-smoking, kleptomaniacal, misanthropic, egocentric, ill-tempered robot. 

    =head2 Dr. John A. Zoidberg 

    Zoidberg is a lobster-like alien from the planet Decapod 10 and is the neurotic staff physician of Planet Express.

    =head1 TAGS

    futurama, bender

 =head1 ATTRIBUTES


=head2 C<toc_tag>

String that is replaced by the TOC (Table of Contents).

    default %TOC%

=head2 C<toc_js_src>

URL to TOC jQuery plugin library

    default: http://samaxesjs.googlecode.com/files/jquery.toc-1.0.2.min.js

=head2 C<toc_exclude>

exlude option, see more here L<http://code.google.com/p/samaxesjs/wiki/TableOfContentsPlugin>

    default: 'h1,#descr,#title,#footer,#nottoc'

=head1 AUTHOR

Konstantin Kapitanov, C<< <perlovik at gmail.com> >> 

=head1 SEE ALSO

L<http://code.google.com/p/samaxesjs/wiki/TableOfContentsPlugin> - TOC (Table of Contents) jQuery plugin

L<http://getbootylicious.org> L<Mojo> L<Mojolicious> L<Mojolicious::Lite>


=head1 COPYRIGHT & LICENSE

Copyright 2009 Konstantin Kapitanov, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
