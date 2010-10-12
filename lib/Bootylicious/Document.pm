package Bootylicious::Document;

use strict;
use warnings;

use base 'Mojo::Base';

__PACKAGE__->attr([qw/path/]);
__PACKAGE__->attr(parsers => sub { {} });
__PACKAGE__->attr(cuttag  => '[cut]');
__PACKAGE__->attr(cuttext => 'Keep reading');

use Bootylicious::Timestamp;

require Carp;
use File::stat;

my $TIMESTAMP_RE = qr/(\d\d\d\d)(\d?\d)(\d?\d)(?:T(\d\d):?(\d\d):?(\d\d))?/;

sub new {
    my $self = shift->SUPER::new(@_);

    my $path = $self->path;

    Carp::croak qq/path is a required parameter/ unless $path;

    Carp::croak qq/$path is not a file i can understand/ unless $self->_parse_path;

    return $self;
}

sub name     { shift->file->{name} }
sub ext      { shift->file->{ext} }
sub filename { shift->file->{filename} }
sub created  { shift->file->{created} }
sub modified { shift->file->{modified} }

sub file {
    my $self = shift;

    return $self->{file} if $self->{file};

    return $self->{file} = $self->_parse_path;
}

sub title       { $_[0]->metadata->{title}       || $_[0]->name }
sub description { shift->metadata->{description} || '' }
sub tags        { shift->metadata->{tags}        || [] }
sub link        { shift->metadata->{link} }

sub metadata {
    my $self = shift;

    return $self->{metadata} if $self->{metadata};

    $self->{metadata} = $self->_parse_metadata;
}

sub preview      { shift->document->{preview}      || '' }
sub preview_link { shift->document->{preview_link} || '' }
sub content      { shift->document->{content}      || '' }

sub document {
    my $self = shift;

    return $self->{document} if $self->{document};

    $self->{document} = $self->_parse_document;
}

sub is_modified {
    my $self = shift;

    return $self->created != $self->modified;
}

sub _parse_path {
    my $self = shift;

    my $path = $self->path;
    return unless $path && -e $path;

    my ($name, $ext) = ($path =~ m/\/([^\/]+)\.([^.]+)$/);
    return unless $name && $ext;

    my $filename = join '.' => $name, $ext;

    my $created;
    if ($name =~ s/^($TIMESTAMP_RE)-//) {
        $created = Bootylicious::Timestamp->new(timestamp => $1)->epoch;
        return unless defined $created;
    }

    my $modified = stat($path)->mtime;
    $created ||= $modified;

    return {
        name     => $name,
        filename => $filename,
        ext      => $ext,
        created  => Bootylicious::Timestamp->new(epoch => $created),
        modified => Bootylicious::Timestamp->new(epoch => $modified)
    };
}

sub _parse_metadata {
    my $self = shift;

    my $path = $self->path;

    open my $fh, '<:encoding(UTF-8)', $path or return;

    my $metadata = {};
    while (my $line = <$fh>) {
        last unless $line;
        last unless $line =~ m/^(.*?): (.*)/;

        my $key   = lc $1;
        my $value = $2;

        if ($key eq 'tags') {
            my $tmp = $value || '';
            $value = [];
            @$value = map { s/^\s+//; s/\s+$//; $_ } split(/,/, $tmp);
        }

        $metadata->{$key} = $value;
    }

    return $metadata;
}

sub _parse_document {
    my ($self) = @_;

    my $parser = $self->parsers->{$self->ext};
    unless ($parser) {
        warn 'No parser found';
        return {};
    }

    open my $fh, '<:encoding(UTF-8)', $self->path or return {};
    while (my $line = <$fh>) {
        last if $line eq '';
        last if $line !~ m/^(.*?): /;
    }

    my $string = '';
    while (my $line = <$fh>) {
        $string .= $line;
    }

    my ($head, $tail, $preview_link_text) = $self->_parse_cuttag(\$string);

    $head = $parser->($head);
    return {} unless $head;

    $tail = $parser->($tail) if $tail;

    my ($preview, $content);

    if ($tail) {
        $content = $head . '<a name="cut"></a>' . $tail;
        $preview = $head;
    }
    else {
        $content = $head;
        $preview = '';
    }

    return {
        preview      => $preview,
        preview_link => $preview_link_text,
        content      => $content
    };
}

sub _parse_cuttag {
    my $self   = shift;
    my $string = shift;

    my $cuttag = $self->cuttag;

    my $tail              = '';
    my $preview_link_text = '';
    if ($$string =~ s{(.*?)\Q$cuttag\E(?: (.*?))?(?:\n|\r|\n\r)(.*)}{$1}s) {
        $tail = $3;
        $preview_link_text = $2 || $self->cuttext;
    }

    return ($$string, $tail, $preview_link_text);
}

1;
