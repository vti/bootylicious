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

sub name     { shift->stat(name     => @_) }
sub format   { shift->stat(format   => @_) }
sub filename { shift->stat(filename => @_) }
sub created  { shift->stat(created  => @_) }
sub modified { shift->stat(modified => @_) }

sub title { my $self = shift; $self->metadata(title => @_) || $self->name }
sub description { shift->metadata(description => @_) }
sub tags        { shift->metadata(tags        => @_) }
sub link        { shift->metadata(link        => @_) }
sub author      { shift->metadata(author      => @_) }

sub has_tags { @{shift->tags || []} ? 1 : 0 }

sub content { shift->_content(content => @_) }

sub stat     { shift->_group(stat     => @_) }
sub metadata { shift->_group(metadata => @_) }
sub _content { shift->_group(content  => @_) }

sub _group {
    my $self   = shift;
    my $group  = shift;
    my $method = shift;

    if (@_) {
        $self->{$group}->{$method} = $_[0];
        return $self;
    }

    return $method ? $self->{$group}->{$method} : $self->{$group}
      if exists $self->{$group};

    my $group_loader = "${group}_loader";
    $self->{$group} = $self->$group_loader->load;

    return $method ? $self->{$group}->{$method} : $self->{$group};
}

sub is_modified {
    my $self = shift;

    return $self->created != $self->modified;
}

1;
