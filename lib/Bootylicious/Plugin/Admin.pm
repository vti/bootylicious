package Bootylicious::Plugin::Admin;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

require Carp;

sub register {
    my ($self, $app, $conf) = @_;

    $conf ||= {};

    Carp::croak qq/Password and username are required for this plugin to work/
      unless $conf->{username} && $conf->{password};

    my %params = (template_class => __PACKAGE__);

    $app->renderer->default_template_class(__PACKAGE__);
    $app->static->default_static_class(__PACKAGE__);

    my $admin =
      $app->routes->waypoint('/admin')
      ->to(%params, cb => \&_index)->name('admin');
    $admin->route('/login')->to(%params, cb => sub {_login(shift, $conf)})->name('admin-login');
    $admin->route('/logout')->to(%params, cb => \&_logout)
      ->name('admin-logout');

    $admin->route('/create_article')
      ->to(%params, cb => \&_create_article)->name('admin-create-article');
    $admin->route('/articles/:year/:month/:name')
      ->to(%params, cb => \&_article)->name('admin-article');

    $app->helper(is_logged_in => sub { shift->session->{admin} ? 1 : 0 });
    $app->helper(logout => sub { shift->session(admin => 0, expires => 1) });
}

sub _index {
    my $self = shift;

    return $self->redirect_to('admin-login') unless $self->is_logged_in;
}

sub _create_article {
    my $self = shift;

    return unless $self->req->method eq 'POST';

    my $validator = $self->create_validator;

    $validator->field('name')->required(1)->regexp(qr/^[a-z0-9-]+$/);
    $validator->field('format')->required(1)->in(keys %{$self->parsers});
    $validator->field('title')->required(1);
    $validator->field('tags');
    $validator->field('content')->required(1);
    $validator->field('link')->url(1);
    $validator->field('author');

    return unless $self->validate($validator);

    Bootylicious::Article->new->create($self->articles_root, $validator->values);

    return $self->redirect_to('admin');
}

sub _article {
    my $self = shift;

    my $article = $self->get_article(@{$self->stash}{qw/year month name/});

    return $self->render_not_found unless $article;

    $self->stash(article => $article);

    return unless $self->req->method eq 'POST';

    my $validator = $self->create_validator;

    $validator->field('title')->required(1);
    $validator->field('tags');
    $validator->field('content')->required(1);
    $validator->field('link')->url(1);
    $validator->field('author');

    return unless $self->validate($validator);

    $article->update($validator->values);

    return $self->redirect_to('admin');
}

sub _login {
    my $self = shift;
    my $conf = shift;

    return $self->render_not_found if $self->is_logged_in;

    return unless $self->req->method eq 'POST';

    my $validator = $self->create_validator;

    $validator->field('username')->required(1);
    $validator->field('password')->required(1);

    return unless $self->validate($validator);

    my $username = $conf->{username};
    my $password = $conf->{password};

    my $values = $validator->values;
    if ($values->{username} eq $username && $values->{password} eq $password)
    {
        $self->session(admin => 1);
        return $self->redirect_to('admin');
    }

    $self->stash(
        validator_errors => {username => 'Wrong username or password'});
}

sub _logout {
    my $self = shift;

    return $self->render_not_found unless $self->is_logged_in;

    $self->logout;

    return $self->redirect_to('admin-login');
}

1;
__DATA__

@@ admin.html.ep
% my $pager = get_articles;
% while (my $article = $pager->articles->next) {
    <%= link_to $article->title, 'admin-article' => {year => $article->created->year, month => $article->created->month, name => $article->name} %><br />
% }

@@ admin-login.html.ep
%= signed_form_for 'admin-login', method => 'post' => begin
    <%= input 'username' %><br />
    <%= validator_error 'username' %><br />
    <%= input 'password', type => 'password' %><br />
    <%= validator_error 'password' %><br />
    <%= submit_button 'Login' %>
% end


@@ admin-create-article.html.ep
%= signed_form_for 'current', method => 'post' => begin
    <%= label 'name' => begin %>Permalink<% end %><br />
    <%= input 'name' %><br />
    <%= validator_error 'name' %>

    <%= label 'title' => begin %>Title<% end %><br />
    <%= input 'title' %><br />
    <%= validator_error 'title' %>

    <%= label 'title' => begin %>Tags<% end %><br />
    <%= input 'tags' %><br />
    <%= validator_error 'tags' %>

    <%= label 'format' => begin %>Format<% end %><br />
    <%= select_field 'format' => [keys %{parsers()}] %><br />
    <%= validator_error 'format' %>

    <%= label 'title' => begin %>Content<% end %><br />
    <%= text_area 'content' => begin %><% end %><br />
    <%= validator_error 'content' %>

    <%= label 'author' => begin %>Author<% end %><br />
    <%= input 'author', value => config 'author' %><br />
    <%= validator_error 'author' %>

    <%= label 'link' => begin %>Link<% end %><br />
    <%= input 'link' %><br />
    <%= validator_error 'link' %>

    <%= submit_button 'Create' %>
% end


@@ admin-article.html.ep
%= signed_form_for 'current', method => 'post' => begin
    <%= label 'title' => begin %>Title<% end %><br />
    <%= input 'title', value => $article->title %><br />
    <%= validator_error 'title' %>

    <%= label 'title' => begin %>Tags<% end %><br />
    <%= input 'tags', value => join ', ' => @{$article->tags} %><br />
    <%= validator_error 'tags' %>

    <%= label 'title' => begin %>Content<% end %><br />
    <%= text_area 'content' => begin %><%= $article->content %><% end %><br />
    <%= validator_error 'content' %>

    <%= label 'author' => begin %>Author<% end %><br />
    <%= input 'author', value => $article->author %><br />
    <%= validator_error 'author' %>

    <%= label 'link' => begin %>Link<% end %><br />
    <%= input 'link', value => $article->link %><br />
    <%= validator_error 'link' %>

    <%= submit_button 'Update' %>
% end


@@ forbidden.html.ep
Forbidden


@@ layouts/wrapper.html.ep
<!doctype html>
    <head>
        <title>Administration / Bootylicious</title>
        <link rel="stylesheet" href="/styles.css" type="text/css" />
    </head>
    <body>
        <div id="header"><%= link_to 'Sign out', 'admin-logout' %></div>
        <%= content %>
    </body>
</html>

@@ styles.css
body {background: #fff;font-family: Georgia, "Bitstream Charter", serif;line-height:25px}
#header {text-align:right}
a,a:active {color:#555}
a:hover{color:#000}
a:visited{color:#000}

input, textarea {font-size:150%;width:60%}
input[type="submit"] {width:20%}
textarea {height:200px}
label {color:#999}
