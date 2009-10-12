package TestController;

use base 'Mojolicious::Controller';

use Mojolicious;
use Mojo::Transaction::Single;

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);

    $self->tx(Mojo::Transaction::Single->new);
    $self->app(Mojolicious->new);

    $self->app->log->level('error');

    return $self;
}

1;
