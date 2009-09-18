package Bootylicious::Plugin::Gallery;

use strict;
use warnings;

use base 'Mojo::Base';

use Digest::MD5 qw( md5_hex );
use Image::Magick::Thumbnail::Fixed;

our $VERSION = '0.04';

my %content_types = (
    'jpg'  => 'image/jpeg',
    'jpeg' => 'image/jpeg',
    'gif'  => 'image/gif',
    'png'  => 'image/png'
);

__PACKAGE__->attr('public_uri'     => '/');
__PACKAGE__->attr('string_to_replace' => '%INSERT_GALLERY_HERE%');
__PACKAGE__->attr('columns'        => 3);
__PACKAGE__->attr('thumb_width'    => 144);
__PACKAGE__->attr('thumb_height'   => 144);
__PACKAGE__->attr('bgcolor'        => 'white');
__PACKAGE__->attr('padding'        => 4);
__PACKAGE__->attr('imagetypes'     => join('|', keys %content_types))
  ;    #  build the list of valid image types


sub hook_finalize {
    my $self = shift;
    my $c    = shift;
    my $path = $c->req->url->path;

    return unless $path =~ /^\/articles/;

    $c->app->log->debug('imagetypes ' . $self->imagetypes);
    my $publicdir = $c->app->home->rel_dir($c->stash('config')->{publicdir});

    my $article = $c->stash('article');

    my $gallery_name = $article->{timestamp} . '-' . $c->stash('alias');

    my $gallerydir = $publicdir . '/' . $gallery_name;

    #not gallery article
    unless (-d $gallerydir) {
        $c->app->log->debug("Not a gallery article: $gallerydir");
        return;
    }

    my $cached_dir = $gallerydir . '/' . 'thumbs';
    if (!-d $cached_dir) {
        unless (mkdir($cached_dir)) {
            $c->app->log->warn("Couldn't make dir  $cached_dir: $!");
            return;
        }

    }
    $c->stash('gallery_name' => $gallery_name);
    $self->print_gallery_thumbs(
        $c,
        {   'gallerydir'   => $gallerydir,
            'publicdir'    => $publicdir,
            'gallery_name' => $gallery_name,
            'cached_dir'   => $cached_dir,
        }
    );
}

sub print_gallery_thumbs {
    my $self       = shift;
    my $c          = shift;
    my $opts       = shift;

    my $publicdir  = $opts->{publicdir};
    my $gallerydir = $opts->{gallerydir};
    my $cached_dir = $opts->{cached_dir};

    my @all_imgs = $self->find_images($c, $opts->{gallerydir});

    my @images = ();
    foreach my $img (@all_imgs) {
        my $hashed_file = $self->_get_hashed_filename($c, $img);
        next unless $hashed_file;

        $self->_cache_image(
            $c,
            {   'source_file' => "$opts->{gallerydir}/$img",
                'cached_file' => "$opts->{cached_dir}/$hashed_file"
            }
        );

        my $thumbnail_url = $self->_build_thumb_url($c, $hashed_file);
        my $large_url = $self->_build_img_url($c, $img);

        push(@images,
            {'thumbnail_url' => $thumbnail_url, 'large_url' => $large_url});
    }
    $c->stash('images' => \@images);
    $c->stash(
        'columns' => $self->columns,
        'padding' => $self->padding,
        'bgcolor' => $self->bgcolor
    );

    my $gallery_html =
      $c->render_partial('gallery', template_class => __PACKAGE__);
    my $body        = $c->res->body;
    my $str_replace = $self->string_to_replace;
    $body =~ s/$str_replace/$gallery_html/;
    $c->res->body($body);
}

sub _build_thumb_url {
    my $self = shift;
    my $c    = shift;
    my $file = shift;

    return $self->public_uri . $c->stash('gallery_name') . '/thumbs/' . $file;
}

sub _build_img_url {
    my $self = shift;
    my $c    = shift;
    my $file = shift;

    return $self->public_uri . $c->stash('gallery_name') . '/' . $file;
}

sub _get_hashed_filename {
    my ($self, $c, $img_path) = @_;

    my ($extension) = $img_path =~ m|\.(\w+)$| or return undef;
    return (md5_hex($img_path) . ".$extension");
}

sub _cache_image {
    my ($self, $c, $opts) = @_;

    return
      if (-e $opts->{cached_file})
      && ((stat($opts->{source_file}))[9] < (stat($opts->{cached_file}))[9]);


    return $self->_create_thubnail($c, $opts);
}

sub _create_thubnail {
    my $self = shift;
    my $c    = shift;
    my $opts = shift;

    my $t = Image::Magick::Thumbnail::Fixed->new();

    $t->thumbnail(
        input   => $opts->{source_file},
        output  => $opts->{cached_file},
        width   => $self->thumb_width,
        height  => $self->thumb_height,
        bgcolor => $self->bgcolor,
    );

    return;
}


sub find_images {
    my ($self, $c, $path) = @_;

    unless (opendir(DIR, $path)) {
        $c->app->log->warn("Couldn't open dir $path: $!");
        return ();
    }

    my @images;
    my $imagetypes = $self->imagetypes;
    foreach my $dentry (readdir(DIR)) {
        my $can_read = -r "$path/$dentry";
        if ($dentry =~ m{\.(?:$imagetypes)$}io && $can_read) {
            push(@images, $dentry);
        }
    }

    unless (closedir(DIR)) {
        $c->app->log->warn("Couldn't close dir $path: $!");
    }

    return sort { $a cmp $b } @images;
}


1;
__DATA__

@@ gallery.html.epl
% my $self = shift;
% my $images = $self->stash('images');
% my $count = 1;
% my $columns =  $self->stash('columns');
% my $pad = $self->stash('padding') / 2;

<center><table cellpadding='<%= $pad %>'><tr>
% foreach my $img (@{$images}) {
   <td><a target=_blank href='<%= $img->{large_url} %>'>
   <img border='0' src='<%= $img->{thumbnail_url} %>'></a></td>
%   if ( $count % $columns == 0 ) {
      </tr><tr>
%   }
%   $count++;
% }
</tr></table></center>


__END__

=head1 NAME

Bootylicious::Plugin::Gallery - Gallery plugin for Bootylicious

=head1 SYNOPSIS

Register gallery plugin in a configuration file (bootylicious.conf), add line
like this:

    "plugins" : [
        "gallery" : {
            "thumb_width" : 144,
            "thumb_height" : 144,
            "bgcolor" : "white"
        }
    ]

Create article (e.g., 20090903-my-super-gallery.pod):

    =head1 NAME

    My foto.

    Hello! There is my super photo gallery.

    [ cut ]

    %INSERT_GALLERY_HERE%

    I'm gonna make my own! With hookers! And blackjack!

    =head1 TAGS

    foto, life

Create directory with photos in publicdir (see in bootylicious.conf
"publicdir" : "..."), e.g., 20090903-my-super-gallery (same as the article).

=head1 DESCRIPTION

L<Bootylicious::Plugin::Gallery> - Gallery plugin for Bootylicious (One-file
blog engine software on Mojo steroids!)

=head1 ATTRIBUTES

=head2 C<public_uri>

Set to public image URL (the same directory as bootylicious.conf publicdir, as
seen by the web browser)

    '/' by default

=head2 C<string_to_replace>

String that is replaced by the gallery.

    '%INSERT_GALLERY_HERE%' by default

=head2 C<columns>

Set this to the number of columns in the thumbnail display.

    3 by default

=head2 C<thumb_width>

Thumbnail width

    144 by default

=head2 C<thumb_height>

Thumbnail height

    144 by default

=head2 C<bgcolor>

Background color of the thumbnail canvas (will only show if the ratio of the
source does not match the ratio of the thumbnail).

    'white' by default

=head2 C<padding>

Set this to the padding (in pixels) between columns

    4 by default

=head2 C<imagetypes>

Set list of valid image types.

    'png|jpg|jpeg|gif' by default

=head1 AUTHOR

Konstantin Kapitanov, C<< <perlovik at gmail.com> >>

=head1 SEE ALSO

L<http://getbootylicious.org> L<Mojo> L<Mojolicious> L<Mojolicious::Lite>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Konstantin Kapitanov, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
