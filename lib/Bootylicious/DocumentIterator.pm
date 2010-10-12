package Bootylicious::DocumentIterator;

use strict;
use warnings;

use base 'Bootylicious::Iterator';

__PACKAGE__->attr('root');
__PACKAGE__->attr('args' => sub { {} });

use Bootylicious::Document;

sub new {
    my $self = shift->SUPER::new(@_);

    return $self if defined $self->elements;

    my $root = $self->root;

    Carp::croak qq/'root' is a required parameter/ unless $root;

    return unless -d $root;

    my @documents = ();

    my @files = glob "$root/*.*";
    foreach my $file (@files) {
        my $document;

        local $@;
        eval {
            $document = $self->create_element(path => $file, %{$self->args});
        };
        next if $@;

        push @documents, $document;
    }

    $self->elements(
        [sort { $b->created->epoch <=> $a->created->epoch } @documents]);

    return $self;
}

sub create_element { shift; Bootylicious::Document->new(@_) }

1;
