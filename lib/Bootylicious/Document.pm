package Bootylicious::Document;

use strict;
use warnings;

use base 'Mojo::Base';

use Bootylicious::DocumentStatLoader;
use Bootylicious::DocumentMetadataLoader;
use Bootylicious::DocumentContentLoader;

require Carp;

__PACKAGE__->attr('path');

__PACKAGE__->attr(
    stat_loader => sub {
        Bootylicious::DocumentStatLoader->new(path => shift->path);
    }
);

__PACKAGE__->attr(
    metadata_loader => sub {
        Bootylicious::DocumentMetadataLoader->new(path => shift->path);
    }
);

__PACKAGE__->attr(
    content_loader => sub {
        Bootylicious::DocumentContentLoader->new(path => shift->path);
    }
);

sub new {
    my $self = shift->SUPER::new(@_);

    my $path = $self->path;

    Carp::croak qq/path is a required parameter/ unless $path;

    return $self;
}

sub name     { shift->_stat(name     => @_) }
sub format   { shift->_stat(format   => @_) }
sub filename { shift->_stat(filename => @_) }
sub created  { shift->_stat(created  => @_) }
sub modified { shift->_stat(modified => @_) }

sub title       { shift->_metadata(title       => @_) }
sub description { shift->_metadata(description => @_) }
sub tags        { shift->_metadata(tags        => @_) }
sub link        { shift->_metadata(link        => @_) }
sub author      { shift->_metadata(author      => @_) }

sub has_tags { @{shift->tags || []} }

sub content { shift->_content(content => @_) }

sub _stat     { shift->_group(stat     => @_) }
sub _metadata { shift->_group(metadata => @_) }
sub _content  { shift->_group(content  => @_) }

sub _group {
    my $self   = shift;
    my $group  = shift;
    my $method = shift;

    if (@_) {
        $self->{$group}->{$method} = $_[0];
        return $self;
    }

    return $self->{$group}->{$method} if exists $self->{$group};

    my $group_loader = "${group}_loader";
    $self->{$group} = $self->$group_loader->load;

    return $self->{$group}->{$method};
}

sub is_modified {
    my $self = shift;

    return $self->created != $self->modified;
}

1;
