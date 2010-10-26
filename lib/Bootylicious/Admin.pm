package Bootylicious::Admin;

use Mojolicious::Lite;

push @{app->plugins->namespaces}, 'Bootylicious::Plugin';

plugin 'booty_config';
plugin 'model';

app->helper(is_logged_in => sub { shift->session->{admin} ? 1 : 0 });
app->helper(logout => sub { shift->session(admin => 0, expires => 1) });

get '/' => sub {
    my $self = shift;

    return $self->redirect_to('login') unless $self->is_logged_in;
} => 'index';

get '/create_article' => sub {
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

    Bootylicious::Article->new->create($self->articles_root,
        $validator->values);

    return $self->redirect_to('admin');
} => 'create-article';

get '/:year/:month/:name' => sub {
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
} => 'article';

any [qw/get post/] => '/login' => sub {
    my $self = shift;

    return $self->render_not_found if $self->is_logged_in;

    return unless $self->req->method eq 'POST';

    my $validator = $self->create_validator;

    $validator->field('username')->required(1);
    $validator->field('password')->required(1);

    return unless $self->validate($validator);

    my $username = $self->stash('conf')->{username};
    my $password = $self->stash('conf')->{password};

    my $values = $validator->values;
    if ($values->{username} eq $username && $values->{password} eq $password)
    {
        $self->session(admin => 1);
        return $self->redirect_to('index');
    }

    $self->stash(
        validator_errors => {username => 'Wrong username or password'});
} => 'login';

get '/logout' => sub {
    my $self = shift;

    return $self->render_not_found unless $self->is_logged_in;

    $self->logout;

    return $self->redirect_to('login');
} => 'logout';

1;
__DATA__

@@ index.html.ep
% my $pager = get_articles;
% while (my $article = $pager->articles->next) {
    <%= link_to $article->title, 'article' => {year => $article->created->year, month => $article->created->month, name => $article->name} %><br />
% }

@@ login.html.ep
%= signed_form_for 'login', method => 'post' => begin
    <%= input_tag 'username' %><br />
    <%= validator_error 'username' %><br />
    <%= input_tag 'password', type => 'password' %><br />
    <%= validator_error 'password' %><br />
    <%= submit_button 'Login' %>
% end


@@ create-article.html.ep
%= signed_form_for 'current', method => 'post' => begin
    <label for 'name'>Permalink</label><br />
    <%= input_tag 'name' %><br />
    <%= validator_error 'name' %>

    <label for 'title'>Title</label><br />
    <%= input_tag 'title' %><br />
    <%= validator_error 'title' %>

    <label for 'tags'>Tags</label><br />
    <%= input_tag 'tags' %><br />
    <%= validator_error 'tags' %>

    <label for 'format'>Format</label><br />
    <%= select_field 'format' => [keys %{parsers()}] %><br />
    <%= validator_error 'format' %>

    <label for 'content'>Content</label><br />
    <%= text_area 'content' => begin %><% end %><br />
    <%= validator_error 'content' %>

    <label for 'author'>Author</label><br />
    <%= input_tag 'author', value => config 'author' %><br />
    <%= validator_error 'author' %>

    <label for 'link'>Link</label><br />
    <%= input_tag 'link' %><br />
    <%= validator_error 'link' %>

    <%= submit_button 'Create' %>
% end


@@ article.html.ep
%= signed_form_for 'current', method => 'post' => begin
    <label for 'title'>Title</label><br />
    <%= input_tag 'title', value => $article->title %><br />
    <%= validator_error 'title' %>

    <label for 'tags'>Tags</label><br />
    <%= input_tag 'tags', value => join ', ' => @{$article->tags} %><br />
    <%= validator_error 'tags' %>

    <label for 'content'>Content</label><br />
    <%= text_area 'content' => begin %><%= $article->content %><% end %><br />
    <%= validator_error 'content' %>

    <label for 'author'>Author</label><br />
    <%= input_tag 'author', value => $article->author %><br />
    <%= validator_error 'author' %>

    <label for 'link'>Link</label><br />
    <%= input_tag 'link', value => $article->link %><br />
    <%= validator_error 'link' %>

    <%= submit_button 'Update' %>
% end


@@ forbidden.html.ep
Forbidden


@@ layouts/wrapper.html.ep
<!doctype html>
    <head>
        <title>Administration / Bootylicious</title>
        <%= stylesheet begin %>
            body {background: #fff;font-family: Georgia, "Bitstream Charter", serif;line-height:25px}
            #header {text-align:right}
            a,a:active {color:#555}
            a:hover{color:#000}
            a:visited{color:#000}

            //input, textarea {font-size:150%;width:60%}
            //input[type="submit"] {width:20%}
            //textarea {height:200px}
            //label {color:#999}
        <% end %>
    </head>
    <body>
        <div id="header"><%= link_to 'Sign out', 'logout' %></div>
        <%= content %>
    </body>
</html>
