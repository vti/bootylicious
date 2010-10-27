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

    return unless -e $path;

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

sub create {
    my $self = shift;
    my $path = shift;
    my $hash = shift;

    if ($hash && ref $hash eq 'HASH') {
        foreach my $key (keys %$hash) {
            $self->$key($hash->{$key});
        }

        $path .= '/'.
            Bootylicious::Timestamp->new(epoch => time)->timestamp . '-'
          . $self->name . '.'
          . $self->format;
    }

    open my $file, '>:encoding(UTF-8)', $path or return;

    $self->path($path);

    my $metadata = '';
    foreach my $key (sort keys %{$self->metadata}) {
        my $value = $self->metadata->{$key};
        next unless $value && $value ne '';
        $metadata .= ucfirst $key . ': ' . $value;
        $metadata .= "\n";
    }

    print $file $metadata;
    print $file "\n";
    print $file $self->content || '';

    return $self;
}

sub update {
    my $self = shift;
    my $hash = shift;

    $hash ||= {};
    foreach my $key (keys %$hash) {
        $self->$key($hash->{$key});
    }

    return $self->create($self->path);
}

sub delete {
    my $self = shift;

    unlink $self->path;
}

1;
