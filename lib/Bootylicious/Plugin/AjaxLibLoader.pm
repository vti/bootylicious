package Bootylicious::Plugin::AjaxLibLoader;

use strict;
use warnings;

use base 'Mojo::Base';

our $VERSION = '0.03';

my %AjaxLibs = (
    'jquery' => [
        '1.3.2',
        'http://ajax.googleapis.com/ajax/libs/jquery/%s/jquery.min.js'
    ],
    'jqueryui' => [
        '1.7.2',
        'http://ajax.googleapis.com/ajax/libs/jqueryui/%s/jquery-ui.min.js'
    ],
    'prototype' => [
        '1.6.1.0',
        'http://ajax.googleapis.com/ajax/libs/prototype/%s/prototype.js'
    ],
    'scriptaculous' => [
        '1.8.2',
        'http://ajax.googleapis.com/ajax/libs/scriptaculous/%s/scriptaculous.js'
    ],
    'mootools' => [
        '1.2.3',
        'http://ajax.googleapis.com/ajax/libs/mootools/%s/mootools-yui-compressed.js'
    ],
    'dojo' => [
        '1.3.2',
        'http://ajax.googleapis.com/ajax/libs/dojo/%s/dojo/dojo.xd.js'
    ],
    'swfobject' => [
        '2.2',
        'http://ajax.googleapis.com/ajax/libs/swfobject/%s/swfobject.js'
    ],
    'yui' => [
        '2.7.0',
        'http://ajax.googleapis.com/ajax/libs/yui/%s/build/yuiloader/yuiloader-min.js'
    ],
    'ext_core' => [
        '3.0.0',
        'http://ajax.googleapis.com/ajax/libs/ext-core/%s/ext-core.js'
    ],
);

__PACKAGE__->attr([keys %AjaxLibs]);

#set default libs versions and paths
foreach my $key (keys %AjaxLibs) {
    __PACKAGE__->attr($key . '_version' => $AjaxLibs{$key}->[0]);
    __PACKAGE__->attr($key . '_path'    => 'all');
}


sub hook_finalize {
    my $self = shift;
    my $c    = shift;
    my ($is_load, $libs) = $self->_to_load($c);
    return unless $is_load;
    $c->stash('libs_to_load' => $libs);
    my $load_html = $c->render_partial('ajax_load',
        template_class => 'Bootylicious::Plugin::AjaxLibLoader');
    my $body = $c->res->body;
    $body =~ s/<[hH][eE][aA][dD]>/<head>\n$load_html\n/;
    $c->res->body($body);

}

sub _to_load {
    my $self = shift;
    my $c    = shift;
    my $path = $c->req->url->path;
    $path =~ s/^\///;
    my @lib_to_load = ();
    my $path_for;
    if ($self->dojo) {
        $path_for = $self->dojo_path;
        if ($path_for eq 'all' or $path =~ /^(?:$path_for)/) {
            push(@lib_to_load,
                {'lib' => 'dojo', 'version' => $self->dojo_version});
        }
    }

    if ($self->ext_core) {
        $path_for = $self->ext_core_path;
        if ($path_for eq 'all' or $path =~ /^(?:$path_for)/) {
            push(@lib_to_load,
                {'lib' => 'ext-core', 'version' => $self->ext_core_version});
        }
    }

    if ($self->jquery) {
        $path_for = $self->jquery_path;
        if ($path_for eq 'all' or $path =~ /^(?:$path_for)/) {
            push(@lib_to_load,
                {'lib' => 'jquery', 'version' => $self->jquery_version});
        }
    }

    if ($self->jqueryui) {
        $path_for = $self->jqueryui_path;
        if ($path_for eq 'all' or $path =~ /^(?:$path_for)/) {
            push(@lib_to_load,
                {'lib' => 'jqueryui', 'version' => $self->jqueryui_version});
        }
    }

    if ($self->mootools) {
        $path_for = $self->mootools_path;
        if ($path_for eq 'all' or $path =~ /^(?:$path_for)/) {
            push(@lib_to_load,
                {'lib' => 'mootools', 'version' => $self->mootools_version});
        }
    }

    if ($self->prototype) {
        $path_for = $self->prototype_path;
        if ($path_for eq 'all' or $path =~ /^(?:$path_for)/) {
            push(@lib_to_load,
                {'lib' => 'prototype', 'version' => $self->prototype_version}
            );
        }
    }

    if ($self->scriptaculous) {
        $path_for = $self->scriptaculous_path;
        if ($path_for eq 'all' or $path =~ /^(?:$path_for)/) {
            push(
                @lib_to_load,
                {   'lib'     => 'scriptaculous',
                    'version' => $self->scriptaculous_version
                }
            );
        }
    }

    if ($self->swfobject) {
        $path_for = $self->swfobject_path;
        if ($path_for eq 'all' or $path =~ /^(?:$path_for)/) {
            push(@lib_to_load,
                {'lib' => 'swfobject', 'version' => $self->swfobject_version}
            );
        }
    }

    if ($self->yui) {
        $path_for = $self->yui_path;
        if ($path_for eq 'all' or $path =~ /^(?:$path_for)/) {
            push(@lib_to_load,
                {'lib' => 'yui', 'version' => $self->yui_version});
        }
    }

    my $is_load = scalar(@lib_to_load);
    return () unless $is_load;

    #build libs url
    foreach my $l (@lib_to_load) {
        $l->{'src_url'} = $self->_build_src_url($l);

    }

    return ($is_load, \@lib_to_load);
}

sub _build_src_url {
    my $self = shift;
    my $data = shift;
    return sprintf($AjaxLibs{$data->{'lib'}}->[1], $data->{'version'});
}

1;
__DATA__

@@ ajax_load.html.epl
% my $self = shift;
% my $libs = $self->stash('libs_to_load');
% foreach my $lib (@{$libs}) {
    <script src="<%= $lib->{'src_url'} %>"></script>
% }

__END__

=head1 NAME

Bootylicious::Plugin::AjaxLibLoader - load popular AJAX JavaScript libraries.

=head1 DESCRIPTION

L<Bootylicious::Plugin::AjaxLibLoader> - this plugin provides your Bootylicious application with stable, reliable, high speed, globally available access to all of the most popular, open source JavaScript libraries (by using content distribution network Google AJAX Libraries API) 

=head1 SYNOPSIS

Register AjaxLibLoader plugin in a configuration file (bootylicious.conf), add line
like this:

    #load JQuery version 1.3.2 for all Bootylicious blog pages

    "plugins" : [
        "ajax_lib_loader", {
            "jquery" : "on",
            "jquery_version" : 1.3.2,
            "jquery_path" : "all"
        }
    ]

    #OR load JQuery version 1.3.2 for all  pages and JQuery UI only for article pages:

    "plugins" : [
        "ajax_lib_loader", {
            "jquery" : "on",
            "jquery_version" : 1.3.2,
            "jquery_path" : "all",
            "jqueryui" : "on",
            "jqueryui_path" : "articles"
        }
    ]

=head1 Ajax libraries

    * Dojo
    * Ext Core
    * jQuery
    * jQuery UI
    * MooTools
    * Prototype
    * script.aculo.us
    * SWFObject
    * Yahoo! User Interface Library (YUI)

=head2 C<Dojo>

Attributes:

    dojo (default false)
    dojo_version (default 1.3.2)
    dojo_path (default all)

Config line example:

    "plugins" : [
        "ajax_lib_loader", {
            "dojo" : "on",
            "dojo_version" : 1.3.2,
            "dojo_path" : "all"
        }
    ]


=head2 C<Ext Core>

Attributes:

    ext_core (default false)
    ext_core_version (default 3.0.0)
    ext_core_path (default all)

Config line example:

    "plugins" : [
        "ajax_lib_loader", {
            "ext-core" : "on",
            "ext-core_version" : 3.0.0,
            "ext-core_path" : "all"
        }
    ]

=head2 C<jQuery>

Attributes:

    jquery (default false)
    jquery_version (default 1.3.2)
    jquery_path (default all)

Config line example:

    "plugins" : [
        "ajax_lib_loader", {
            jquery" : "on",
            jquery_version" : 1.3.2,
            jquery_path" : "all"
        }
    ]


=head2 C<jQuery UI>

Attributes:

    jqueryui (default false)
    jqueryui_version (default 1.7.2)
    jqueryui_path (default all)

Config line example:

    "plugins" : [
        "ajax_lib_loader", {
            "jqueryui" : "on",
            "jqueryui_version" : 1.7.2,
            "jqueryui_path" : "all"
        }
    ]

=head2 C<MooTools>

Attributes:

    mootools (default false)
    mootools_version (default 1.2.3)
    mootools_path (default all)

Config line example:

    "plugins" : [
        "ajax_lib_loader", {
            "mootools" : "on",
            "mootools_version" : 1.2.3,
            "mootools_path" : "all"
        }
    ]

=head2 C<Prototype>

Attributes:

    prototype (default false)
    prototype_version (default 1.6.1.0)
    prototype_path (default all)

Config line example:

    "plugins" : [
        "ajax_lib_loader", {
            "prototype" : "on",
            "prototype_version" : 1.6.1.0,
            "prototype_path" : "all"
        }
    ]

=head2 C<script.aculo.us>

Attributes:

    scriptaculous (default false)
    scriptaculous_version (default 1.8.2)
    scriptaculous_path (default all)

Config line example:

    "plugins" : [
        "ajax_lib_loader", {
            "scriptaculous" : "on",
            "scriptaculous_version" : 1.8.2,
            "scriptaculous_path" : "all"
        }
    ]

=head2 C<SWFObject>

Attributes:

    swfobject (default false)
    swfobject_version (default 2.2)
    swfobject_path (default all)

Config line example:

    "plugins" : [
        "ajax_lib_loader", {
            "swfobject" : "on",
            "swfobject_version" : 2.2,
            "swfobject_path" : "all"
        }
    ]

=head2 C<Yahoo! User Interface Library (YUI)>

Attributes:

    yui (default false)
    yui_version (default 2.7.0)
    yui_path (default all)

Config line example:

    "plugins" : [
        "ajax_lib_loader", {
            "yui" : "on",
            "yui_version" : 2.7.0,
            "yui_path" : "all"
        }
    ]

=head1 AUTHOR

Konstantin Kapitanov, C<< <perlovik at gmail.com> >> 

=head1 SEE ALSO

L<http://code.google.com/apis/ajaxlibs/> - Google AJAX Libraries API

L<http://getbootylicious.org> L<Mojo> L<Mojolicious> L<Mojolicious::Lite>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Konstantin Kapitanov, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
