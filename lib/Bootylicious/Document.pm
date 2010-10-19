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
    inner_loader => sub {
        Bootylicious::DocumentContentLoader->new(path => shift->path);
    }
);

sub load {
    my $self = shift;
    my $path = shift;

    $self->path($path);

    return $self;
}

sub name     { shift->stat(name     => @_) }
sub format   { shift->stat(format   => @_) }
sub filename { shift->stat(filename => @_) }
sub created  { shift->stat(created  => @_) }
sub modified { shift->stat(modified => @_) }

sub author { shift->metadata(author => @_) }

sub content { shift->inner(content => @_) }

sub stat     { shift->_group(stat     => @_) }
sub metadata { shift->_group(metadata => @_) }
sub inner    { shift->_group(inner    => @_) }

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
