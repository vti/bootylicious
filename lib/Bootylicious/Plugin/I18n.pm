package Bootylicious::Plugin::I18n;

use strict;
use warnings;

use base 'Mojo::Base';

use MojoX::Locale::Maketext;
use POSIX qw(locale_h);

__PACKAGE__->attr('languages' => 'en');
__PACKAGE__->attr('helper' => 'loc');

sub hook_init {
    my $self = shift;
    my $app  = shift;

    my $i18n = MojoX::Locale::Maketext->new;

    $i18n->setup(namespace => 'Bootylicious', subclass => 'I18N');

    my $languages = $self->languages;
    $languages = [$languages] unless ref($languages) eq 'ARRAY';

    $i18n->languages($languages);

    setlocale(LC_ALL, $languages->[0]);

    my $strings = main::config('strings');

    foreach my $key (keys %$strings) {
        $strings->{$key} = $i18n->loc($strings->{$key});
    }

    main::config(strings => $strings);

    $app->renderer->add_handler(
        $self->helper => sub {
            my $c = shift;

            return $i18n->localize(@_);
        }
    );
}

1;
