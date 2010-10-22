package Bootylicious::Theme::WordpressTwentyten;

use strict;
use warnings;

use base 'Bootylicious::Theme';

sub register {
    my ($self, $app, $conf) = @_;

    $app->helper(
        menu => sub {
            my $self = shift;

            my @links;

            my $menu = $self->config('menu');

            for (my $i = 0; $i < @$menu; $i += 2) {
                my $title = $menu->[$i];
                my $href  = $menu->[$i + 1];

                push @links, '<li class="current_page_item">' .  $self->link_to($href => sub {$title}) . '</li>';
            }

            return Mojo::ByteStream->new('<ul>' . join(' ' => @links). ' </ul>');
        }
    );
}

1;
__DATA__

@@ index.html.ep
% while (my $article = $articles->next) {
<div id="post-5" class="post-5 post type-post hentry category-uncategorized">
    <h2 class="entry-title">
        <%= link_to_article $article %>
    </h2>

    %= include 'article-meta', article => $article;

    <div class="entry-content">
        <%= render_article_or_preview $article %>
    </div><!-- .entry-content -->

    <div class="entry-utility">
    % if ($article->has_tags) {
        Tagged <%= tags_links $article %>. |
    % }
    <%= link_to_comments $article %>
    </div><!-- .entry-utility -->
</div><!-- #post-## -->
% }


@@ article.html.ep
<div class="post type-post hentry">
    <h2 class="entry-title">
        <%= link_to_article $article %>
    </h2>

    %= include 'article-meta', article => $article;

    <div class="entry-content">
        <%= render_article $article %>
    </div><!-- .entry-content -->

    <div class="entry-utility">
        % if ($article->has_tags) {
        This entry was tagged <%= tags_links $article %>.
        % }
        Bookmark the <%= link_to_article $article => begin %>permalink<% end %>.
    </div><!-- .entry-utility -->

    <br />

    <div id="nav-below" class="navigation">
        <div class="nav-previous"><%= link_to_article $article->prev if $article->prev %></div>
        <div class="nav-next"><%= link_to_article $article->next if $article->next %></div>
    </div><!-- #nav-below -->

</div><!-- #post-## -->


@@ article-meta.html.ep
    <div class="entry-meta">
        <span class="meta-prep meta-prep-author">Posted on</span> <%= link_to_article $article => {%><span class="entry-date"><%= date $article->created %></span><%}%> <span class="meta-sep">by</span> <span class="author vcard"><%= link_to_author $article->author %></span>
    </div><!-- .entry-meta -->


@@ articles.html.ep
% if ($archive->is_monthly) {
    <h1 class="page-title">Monthly Archives: <span><%= $archive->month_name %> <%= $archive->year %></span></h1>
    %= include 'archive-monthly', articles => $archive->articles;
% }
% else {
    <h1 class="page-title">Yearly Archives: <span><%= $archive->year %></span></h1>
    %= include 'archive-yearly', archive => $archive;
% }


@@ archive-yearly.html.ep
% while (my $year = $archive->next) {
    %= include 'archive-monthly', articles => $year->articles;
% }


@@ archive-monthly.html.ep
% while (my $article = $articles->next) {
<div id="post-5" class="post-5 post type-post hentry">
    <h2 class="entry-title">
        <%= link_to_article $article %>
    </h2>

    %= include 'article-meta', article => $article;

    <div class="entry-content">
        <%= render_article_or_preview $article %>
    </div><!-- .entry-content -->

    <div class="entry-utility">
    % if ($article->has_tags) {
        This entry was tagged <%= tags_links $article %>.
    % }
    Bookmark the <%= link_to_article $article => begin %>permalink<% end %>.
    </div><!-- .entry-utility -->
</div>
% }


@@ tag.html.ep
% while (my $article = $articles->next) {
<div id="post-5" class="post-5 post type-post hentry">
    <h2 class="entry-title">
        <%= link_to_article $article %>
    </h2>

    %= include 'article-meta', article => $article;

    <div class="entry-content">
        <%= render_article_or_preview $article %>
    </div><!-- .entry-content -->

    <div class="entry-utility">
    % if ($article->has_tags) {
        This entry was tagged <%= tags_links $article %>.
    % }
    Bookmark the <%= link_to_article $article => begin %>permalink<% end %>.
    </div><!-- .entry-utility -->
</div>
% }


@@ layouts/wrapper.html.ep
<!DOCTYPE html>
<html dir="ltr" lang="ru-RU">
<head>
<meta charset="UTF-8" />
<title><%= config 'title' %></title>
<link rel="stylesheet" type="text/css" media="all" href="/style.css" />
<link rel="alternate" type="application/rss+xml" title="<%= config 'title' %> &raquo; Feed" href="<%= href_to_rss %>" />
<link rel="alternate" type="application/rss+xml" title="<%= config 'title' %> &raquo; Comments Feed" href="<%= href_to_comments_rss %>" />
<link rel='index' title='<%= config 'title' %>' href='<%= url_for('index')->to_abs %>' />
<meta name="generator" content="<%= generator %>" />
</head>

<body class="home blog">
    <div id="wrapper" class="hfeed">
        <div id="header">
            <div id="masthead">
                <div id="branding" role="banner">
                    <h1 id="site-title">
                        <span>
                            <%= link_to 'index' => {%><%= config 'title' %><%}%>
                        </span>
                    </h1>
                    <div id="site-description"><%= config 'descr' %></div>

                    <img src="/path.jpg" width="940" height="198" alt="" />
                </div><!-- #branding -->

                <div id="access" role="navigation">
                    <div class="skip-link screen-reader-text"><a href="#content" title="Skip to content">Skip to content</a></div>
                    <div class="menu"><%= menu %></div>
                </div><!-- #access -->
            </div><!-- #masthead -->
        </div><!-- #header -->

        <div id="main">

            <div id="container">
                <div id="content" role="main">
                    <%= content %>
                </div><!-- #content -->
            </div><!-- #container -->

            <div id="primary" class="widget-area" role="complementary">
                <ul class="xoxo">

                    <li id="search-2" class="widget-container widget_search">

                    <%= form_for 'search', method => 'get', id => 'searchform' => begin %>
                    <div><label class="screen-reader-text" for="s">Find:</label>
                        <%= input 'q', id => 's' %>
                        <%= submit_button 'Search', id => 'searchsubmit' %>
                    </div>
                    <% end %>

                    </li>
                    <li id="tags" class="widget-container widget_tags">
                        <h3 class="widget-title">Tags</h3>
                        % my $tags = get_tag_cloud;
                        % while (my $tag = $tags->next) {
                        <%= link_to_tag $tag %>
                        % }
                    </li>
                    <li id="recent-posts-2" class="widget-container widget_recent_entries">
                        <h3 class="widget-title">Recent posts</h3>
                        <ul>
                            % my $recent_articles = get_recent_articles;
                            % while (my $article = $recent_articles->next) {
                            <li><%= link_to_article $article %></li>
                            % }
                        </ul>
                    </li>
                    <li id="recent-comments-2" class="widget-container widget_recent_comments">
                        <h3 class="widget-title">Recent comments</h3>
                        <ul>
                            % my $recent_comments = get_recent_comments;
                            % while (my $comment = $recent_comments->next) {
                            <li><%= comment_author $comment %> on <%= link_to_comment $comment %></li>
                            % }
                        </ul>
                    </li>
                    <li id="archives-2" class="widget-container widget_archive">
                        <h3 class="widget-title">Archives</h3>
                        <ul>
                            % my $archive = get_archive_simple;
                            % foreach my $pair (@$archive) {
                            <li>
                            <%= link_to_archive $pair->[0], $pair->[1] %>
                            </li>
                            % }
                        </ul>
                    </li>
                    <li id="meta-2" class="widget-container widget_meta">
                    <h3 class="widget-title">Meta</h3>
                    <ul>
                        <li><%= link_to_rss title => 'Subscribe' => begin %>Entries <abbr title="Really Simple Syndication">RSS</abbr></a><% end %></li>
                        <li><%= link_to_comments_rss title => 'Subscribe' => begin %>Comments <abbr title="Really Simple Syndication">RSS</abbr></a><% end %></li>
                    <li><%= link_to_bootylicious %></li>
                </ul>
                </li>
            </ul>
        </div><!-- #primary .widget-area -->

    </div><!-- #main -->

    <div id="footer" role="contentinfo">
        <div id="colophon">
            <div id="site-info">
                <%= link_to_home %>
            </div><!-- #site-info -->

            <div id="site-generator">
                <%= powered_by %>. Wordpress twentyten theme.
            </div><!-- #site-generator -->

        </div><!-- #colophon -->
    </div><!-- #footer -->

</div><!-- #wrapper -->

</body>
</html>

@@ style.css
/*
Theme Name: Twenty Ten
Theme URI: http://wordpress.org/
Description: The 2010 theme for WordPress is stylish, customizable, simple, and readable -- make it yours with a custom menu, header image, and background. Twenty Ten supports six widgetized areas (two in the sidebar, four in the footer) and featured images (thumbnails for gallery posts and custom header images for posts and pages). It includes stylesheets for print and the admin Visual Editor, special styles for posts in the "Asides" and "Gallery" categories, and has an optional one-column page template that removes the sidebar.
Author: the WordPress team
Version: 1.1
Tags: black, blue, white, two-columns, fixed-width, custom-header, custom-background, threaded-comments, sticky-post, translation-ready, microformats, rtl-language-support, editor-style
*/


/* =Reset default browser CSS. Based on work by Eric Meyer: http://meyerweb.com/eric/tools/css/reset/index.html
-------------------------------------------------------------- */

html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, font, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td {
	background: transparent;
	border: 0;
	margin: 0;
	padding: 0;
	vertical-align: baseline;
}
body {
	line-height: 1;
}
h1, h2, h3, h4, h5, h6 {
	clear: both;
	font-weight: normal;
}
ol, ul {
	list-style: none;
}
blockquote {
	quotes: none;
}
blockquote:before, blockquote:after {
	content: '';
	content: none;
}
del {
	text-decoration: line-through;
}
/* tables still need 'cellspacing="0"' in the markup */
table {
	border-collapse: collapse;
	border-spacing: 0;
}
a img {
	border: none;
}

/* =Layout
-------------------------------------------------------------- */

/*
LAYOUT: Two columns
DESCRIPTION: Two-column fixed layout with one sidebar right of content
*/

#container {
	float: left;
	margin: 0 -240px 0 0;
	width: 100%;
}
#content {
	margin: 0 280px 0 20px;
}
#primary,
#secondary {
	float: right;
	overflow: hidden;
	width: 220px;
}
#secondary {
	clear: right;
}
#footer {
	clear: both;
	width: 100%;
}

/*
LAYOUT: One column, no sidebar
DESCRIPTION: One centered column with no sidebar
*/

.one-column #content {
	margin: 0 auto;
	width: 640px;
}

/*
LAYOUT: Full width, no sidebar
DESCRIPTION: Full width content with no sidebar; used for attachment pages
*/

.single-attachment #content {
	margin: 0 auto;
	width: 900px;
}


/* =Fonts
-------------------------------------------------------------- */
body,
input,
textarea,
.page-title span,
.pingback a.url {
	font-family: Georgia, "Bitstream Charter", serif;
}
h3#comments-title,
h3#reply-title,
#access .menu,
#access div.menu ul,
#cancel-comment-reply-link,
.form-allowed-tags,
#site-info,
#site-title,
#wp-calendar,
.comment-meta,
.comment-body tr th,
.comment-body thead th,
.entry-content label,
.entry-content tr th,
.entry-content thead th,
.entry-meta,
.entry-title,
.entry-utility,
#respond label,
.navigation,
.page-title,
.pingback p,
.reply,
.widget-title,
.wp-caption-text,
input[type=submit] {
	font-family: "Helvetica Neue", Arial, Helvetica, "Nimbus Sans L", sans-serif;
}
pre {
	font-family: "Courier 10 Pitch", Courier, monospace;
}
code {
	font-family: Monaco, Consolas, "Andale Mono", "DejaVu Sans Mono", monospace;
}


/* =Structure
-------------------------------------------------------------- */

/* The main theme structure */
#access .menu-header,
div.menu,
#colophon,
#branding,
#main,
#wrapper {
	margin: 0 auto;
	width: 940px;
}
#wrapper {
	background: #fff;
	margin-top: 20px;
	padding: 0 20px;
}

/* Structure the footer area */
#footer-widget-area {
	overflow: hidden;
}
#footer-widget-area .widget-area {
	float: left;
	margin-right: 20px;
	width: 220px;
}
#footer-widget-area #fourth {
	margin-right: 0;
}
#site-info {
	float: left;
	font-size: 14px;
	font-weight: bold;
	width: 700px;
}
#site-generator {
	float: right;
	width: 350px;
}


/* =Global Elements
-------------------------------------------------------------- */

/* Main global 'theme' and typographic styles */
body {
	background: #f1f1f1;
}
body,
input,
textarea {
	color: #666;
	font-size: 12px;
	line-height: 18px;
}
hr {
	background-color: #e7e7e7;
	border: 0;
	clear: both;
	height: 1px;
	margin-bottom: 18px;
}

/* Text elements */
p {
	margin-bottom: 18px;
}
ul {
	list-style: square;
	margin: 0 0 18px 1.5em;
}
ol {
	list-style: decimal;
	margin: 0 0 18px 1.5em;
}
ol ol {
	list-style: upper-alpha;
}
ol ol ol {
	list-style: lower-roman;
}
ol ol ol ol {
	list-style: lower-alpha;
}
ul ul,
ol ol,
ul ol,
ol ul {
	margin-bottom: 0;
}
dl {
	margin: 0 0 24px 0;
}
dt {
	font-weight: bold;
}
dd {
	margin-bottom: 18px;
}
strong {
	font-weight: bold;
}
cite,
em,
i {
	font-style: italic;
}
big {
	font-size: 131.25%;
}
ins {
	background: #ffc;
	text-decoration: none;
}
blockquote {
	font-style: italic;
	padding: 0 3em;
}
blockquote cite,
blockquote em,
blockquote i {
	font-style: normal;
}
pre {
	background: #f7f7f7;
	color: #222;
	line-height: 18px;
	margin-bottom: 18px;
	padding: 1.5em;
}
abbr,
acronym {
	border-bottom: 1px dotted #666;
	cursor: help;
}
sup,
sub {
	height: 0;
	line-height: 1;
	position: relative;
	vertical-align: baseline;
}
sup {
	bottom: 1ex;
}
sub {
	top: .5ex;
}
input[type="text"],
textarea {
	background: #f9f9f9;
	border: 1px solid #ccc;
	box-shadow: inset 1px 1px 1px rgba(0,0,0,0.1);
	-moz-box-shadow: inset 1px 1px 1px rgba(0,0,0,0.1);
	-webkit-box-shadow: inset 1px 1px 1px rgba(0,0,0,0.1);
	padding: 2px;
}
a:link {
	color: #0066cc;
}
a:visited {
	color: #743399;
}
a:active,
a:hover {
	color: #ff4b33;
}

/* Text meant only for screen readers */
.screen-reader-text {
	position: absolute;
	left: -9000px;
}


/* =Header
-------------------------------------------------------------- */

#header {
	padding: 30px 0 0 0;
}
#site-title {
	float: left;
	font-size: 30px;
	line-height: 36px;
	margin: 0 0 18px 0;
	width: 700px;
}
#site-title a {
	color: #000;
	font-weight: bold;
	text-decoration: none;
}
#site-description {
	clear: right;
	float: right;
	font-style: italic;
	margin: 14px 0 18px 0;
	width: 220px;
}

/* This is the custom header image */
#branding img {
	border-top: 4px solid #000;
	border-bottom: 1px solid #000;
	clear: both;
	display: block;
}


/* =Menu
-------------------------------------------------------------- */

#access {
	background: #000;
	display: block;
	float: left;
	margin: 0 auto;
	width: 940px;
}
#access .menu-header,
div.menu {
	font-size: 13px;
	margin-left: 12px;
	width: 928px;
}
#access .menu-header ul,
div.menu ul {
	list-style: none;
	margin: 0;
}
#access .menu-header li,
div.menu li {
	float: left;
	position: relative;
}
#access a {
	color: #aaa;
	display: block;
	line-height: 38px;
	padding: 0 10px;
	text-decoration: none;
}
#access ul ul {
	box-shadow: 0px 3px 3px rgba(0,0,0,0.2);
	-moz-box-shadow: 0px 3px 3px rgba(0,0,0,0.2);
	-webkit-box-shadow: 0px 3px 3px rgba(0,0,0,0.2);
	display: none;
	position: absolute;
	top: 38px;
	left: 0;
	float: left;
	width: 180px;
	z-index: 99999;
}
#access ul ul li {
	min-width: 180px;
}
#access ul ul ul {
	left: 100%;
	top: 0;
}
#access ul ul a {
	background: #333;
	line-height: 1em;
	padding: 10px;
	width: 160px;
	height: auto;
}
#access li:hover > a,
#access ul ul :hover > a {
	background: #333;
	color: #fff;
}
#access ul li:hover > ul {
	display: block;
}
#access ul li.current_page_item > a,
#access ul li.current-menu-ancestor > a,
#access ul li.current-menu-item > a,
#access ul li.current-menu-parent > a {
	color: #fff;
}
* html #access ul li.current_page_item a,
* html #access ul li.current-menu-ancestor a,
* html #access ul li.current-menu-item a,
* html #access ul li.current-menu-parent a,
* html #access ul li a:hover {
	color: #fff;
}


/* =Content
-------------------------------------------------------------- */

#main {
	clear: both;
	overflow: hidden;
	padding: 40px 0 0 0;
}
#content {
	margin-bottom: 36px;
}
#content,
#content input,
#content textarea {
	color: #333;
	font-size: 16px;
	line-height: 24px;
}
#content p,
#content ul,
#content ol,
#content dd,
#content pre,
#content hr {
	margin-bottom: 24px;
}
#content ul ul,
#content ol ol,
#content ul ol,
#content ol ul {
	margin-bottom: 0;
}
#content pre,
#content kbd,
#content tt,
#content var {
	font-size: 15px;
	line-height: 21px;
}
#content code {
	font-size: 13px;
}
#content dt,
#content th {
	color: #000;
}
#content h1,
#content h2,
#content h3,
#content h4,
#content h5,
#content h6 {
	color: #000;
	line-height: 1.5em;
	margin: 0 0 20px 0;
}
#content table {
	border: 1px solid #e7e7e7;
	margin: 0 -1px 24px 0;
	text-align: left;
	width: 100%;
}
#content tr th,
#content thead th {
	color: #888;
	font-size: 12px;
	font-weight: bold;
	line-height: 18px;
	padding: 9px 24px;
}
#content tr td {
	border-top: 1px solid #e7e7e7;
	padding: 6px 24px;
}
#content tr.odd td {
	background: #f2f7fc;
}
.hentry {
	margin: 0 0 48px 0;
}
.home .sticky {
	background: #f2f7fc;
	border-top: 4px solid #000;
	margin-left: -20px;
	margin-right: -20px;
	padding: 18px 20px;
}
.single .hentry {
	margin: 0 0 36px 0;
}
.page-title {
	color: #000;
	font-size: 14px;
	font-weight: bold;
	margin: 0 0 36px 0;
}
.page-title span {
	color: #333;
	font-size: 16px;
	font-style: italic;
	font-weight: normal;
}
.page-title a:link,
.page-title a:visited {
	color: #888;
	text-decoration: none;
}
.page-title a:active,
.page-title a:hover {
	color: #ff4b33;
}
#content .entry-title {
	color: #000;
	font-size: 21px;
	font-weight: bold;
	line-height: 1.3em;
	margin-bottom: 0;
}
.entry-title a:link,
.entry-title a:visited {
	color: #000;
	text-decoration: none;
}
.entry-title a:active,
.entry-title a:hover {
	color: #ff4b33;
}
.entry-meta {
	color: #888;
	font-size: 12px;
}
.entry-meta abbr,
.entry-utility abbr {
	border: none;
}
.entry-meta abbr:hover,
.entry-utility abbr:hover {
	border-bottom: 1px dotted #666;
}
.entry-content,
.entry-summary {
	clear: both;
	padding: 12px 0 0 0;
}
#content .entry-summary p:last-child {
	margin-bottom: 12px;
}
.entry-content fieldset {
	border: 1px solid #e7e7e7;
	margin: 0 0 24px 0;
	padding: 24px;
}
.entry-content fieldset legend {
	background: #fff;
	color: #000;
	font-weight: bold;
	padding: 0 24px;
}
.entry-content input {
	margin: 0 0 24px 0;
}
.entry-content input.file,
.entry-content input.button {
	margin-right: 24px;
}
.entry-content label {
	color: #888;
	font-size: 12px;
}
.entry-content select {
	margin: 0 0 24px 0;
}
.entry-content sup,
.entry-content sub {
	font-size: 10px;
}
.entry-content blockquote.left {
	float: left;
	margin-left: 0;
	margin-right: 24px;
	text-align: right;
	width: 33%;
}
.entry-content blockquote.right {
	float: right;
	margin-left: 24px;
	margin-right: 0;
	text-align: left;
	width: 33%;
}
.page-link {
	color: #000;
	font-weight: bold;
	margin: 0 0 22px 0;
	word-spacing: 0.5em;
}
.page-link a:link,
.page-link a:visited {
	background: #f1f1f1;
	color: #333;
	font-weight: normal;
	padding: 0.5em 0.75em;
	text-decoration: none;
}
.home .sticky .page-link a {
	background: #d9e8f7;
}
.page-link a:active,
.page-link a:hover {
	color: #ff4b33;
}
body.page .edit-link {
	clear: both;
	display: block;
}
#entry-author-info {
	background: #f2f7fc;
	border-top: 4px solid #000;
	clear: both;
	font-size: 14px;
	line-height: 20px;
	margin: 24px 0;
	overflow: hidden;
	padding: 18px 20px;
}
#entry-author-info #author-avatar {
	background: #fff;
	border: 1px solid #e7e7e7;
	float: left;
	height: 60px;
	margin: 0 -104px 0 0;
	padding: 11px;
}
#entry-author-info #author-description {
	float: left;
	margin: 0 0 0 104px;
}
#entry-author-info h2 {
	color: #000;
	font-size: 100%;
	font-weight: bold;
	margin-bottom: 0;
}
.entry-utility {
	clear: both;
	color: #888;
	font-size: 12px;
	line-height: 18px;
}
.entry-meta a,
.entry-utility a {
	color: #888;
}
.entry-meta a:hover,
.entry-utility a:hover {
	color: #ff4b33;
}
#content .video-player {
	padding: 0;
}


/* =Asides
-------------------------------------------------------------- */

.home #content .category-asides p {
	font-size: 14px;
	line-height: 20px;
	margin-bottom: 10px;
	margin-top: 0;
}
.home .hentry.category-asides {
	padding: 0;
}
.home #content .category-asides .entry-content {
	padding-top: 0;
}


/* =Gallery listing
-------------------------------------------------------------- */

.category-gallery .size-thumbnail img {
	border: 10px solid #f1f1f1;
	margin-bottom: 0;
}
.category-gallery .gallery-thumb {
	float: left;
	margin-right: 20px;
	margin-top: -4px;
}
.home #content .category-gallery .entry-utility {
	padding-top: 4px;
}


/* =Attachment pages
-------------------------------------------------------------- */

.attachment .entry-content .entry-caption {
	font-size: 140%;
	margin-top: 24px;
}
.attachment .entry-content .nav-previous a:before {
	content: '\2190\00a0';
}
.attachment .entry-content .nav-next a:after {
	content: '\00a0\2192';
}


/* =Images
-------------------------------------------------------------- */

#content img {
	margin: 0;
	height: auto;
	max-width: 640px;
	width: auto;
}
#content .attachment img {
	max-width: 900px;
}
#content .alignleft,
#content img.alignleft {
	display: inline;
	float: left;
	margin-right: 24px;
	margin-top: 4px;
}
#content .alignright,
#content img.alignright {
	display: inline;
	float: right;
	margin-left: 24px;
	margin-top: 4px;
}
#content .aligncenter,
#content img.aligncenter {
	clear: both;
	display: block;
	margin-left: auto;
	margin-right: auto;
}
#content img.alignleft,
#content img.alignright,
#content img.aligncenter {
	margin-bottom: 12px;
}
#content .wp-caption {
	background: #f1f1f1;
	line-height: 18px;
	margin-bottom: 20px;
	padding: 4px;
	text-align: center;
}
#content .wp-caption img {
	margin: 5px 5px 0;
}
#content .wp-caption p.wp-caption-text {
	color: #888;
	font-size: 12px;
	margin: 5px;
}
#content .wp-smiley {
	margin: 0;
}
#content .gallery {
	margin: 0 auto 18px;
}
#content .gallery .gallery-item {
	float: left;
	margin-top: 0;
	text-align: center;
	width: 33%;
}
#content .gallery img {
	border: 2px solid #cfcfcf;
}
#content .gallery .gallery-caption {
	color: #888;
	font-size: 12px;
	margin: 0 0 12px;
}
#content .gallery dl {
	margin: 0;
}
#content .gallery img {
	border: 10px solid #f1f1f1;
}
#content .gallery br+br {
	display: none;
}
#content .attachment img { /* single attachment images should be centered */
	display: block;
	margin: 0 auto;
}


/* =Navigation
-------------------------------------------------------------- */

.navigation {
	color: #888;
	font-size: 12px;
	line-height: 18px;
	overflow: hidden;
}
.navigation a:link,
.navigation a:visited {
	color: #888;
	text-decoration: none;
}
.navigation a:active,
.navigation a:hover {
	color: #ff4b33;
}
.nav-previous {
	float: left;
	width: 50%;
}
.nav-next {
	float: right;
	text-align: right;
	width: 50%;
}
#nav-above {
	margin: 0 0 18px 0;
}
#nav-above {
	display: none;
}
.paged #nav-above,
.single #nav-above {
	display: block;
}
#nav-below {
	margin: -18px 0 0 0;
}


/* =Comments
-------------------------------------------------------------- */
#comments {
	clear: both;
}
#comments .navigation {
	padding: 0 0 18px 0;
}
h3#comments-title,
h3#reply-title {
	color: #000;
	font-size: 20px;
	font-weight: bold;
	margin-bottom: 0;
}
h3#comments-title {
	padding: 24px 0;
}
.commentlist {
	list-style: none;
	margin: 0;
}
.commentlist li.comment {
	border-bottom: 1px solid #e7e7e7;
	line-height: 24px;
	margin: 0 0 24px 0;
	padding: 0 0 0 56px;
	position: relative;
}
.commentlist li:last-child {
	border-bottom: none;
	margin-bottom: 0;
}
#comments .comment-body ul,
#comments .comment-body ol {
	margin-bottom: 18px;
}
#comments .comment-body p:last-child {
	margin-bottom: 6px;
}
#comments .comment-body blockquote p:last-child {
	margin-bottom: 24px;
}
.commentlist ol {
	list-style: decimal;
}
.commentlist .avatar {
	position: absolute;
	top: 4px;
	left: 0;
}
.comment-author {
}
.comment-author cite {
	color: #000;
	font-style: normal;
	font-weight: bold;
}
.comment-author .says {
	font-style: italic;
}
.comment-meta {
	font-size: 12px;
	margin: 0 0 18px 0;
}
.comment-meta a:link,
.comment-meta a:visited {
	color: #888;
	text-decoration: none;
}
.comment-meta a:active,
.comment-meta a:hover {
	color: #ff4b33;
}
.commentlist .even {
}
.commentlist .bypostauthor {
}
.reply {
	font-size: 12px;
	padding: 0 0 24px 0;
}
.reply a,
a.comment-edit-link {
	color: #888;
}
.reply a:hover,
a.comment-edit-link:hover {
	color: #ff4b33;
}
.commentlist .children {
	list-style: none;
	margin: 0;
}
.commentlist .children li {
	border: none;
	margin: 0;
}
.nopassword,
.nocomments {
	display: none;
}
#comments .pingback {
	border-bottom: 1px solid #e7e7e7;
	margin-bottom: 18px;
	padding-bottom: 18px;
}
.commentlist li.comment+li.pingback {
	margin-top: -6px;
}
#comments .pingback p {
	color: #888;
	display: block;
	font-size: 12px;
	line-height: 18px;
	margin: 0;
}
#comments .pingback .url {
	font-size: 13px;
	font-style: italic;
}

/* Comments form */
input[type=submit] {
	color: #333;
}
#respond {
	border-top: 1px solid #e7e7e7;
	margin: 24px 0;
	overflow: hidden;
	position: relative;
}
#respond p {
	margin: 0;
}
#respond .comment-notes {
	margin-bottom: 1em;
}
.form-allowed-tags {
	line-height: 1em;
}
.children #respond {
	margin: 0 48px 0 0;
}
h3#reply-title {
	margin: 18px 0;
}
#comments-list #respond {
	margin: 0 0 18px 0;
}
#comments-list ul #respond {
	margin: 0;
}
#cancel-comment-reply-link {
	font-size: 12px;
	font-weight: normal;
	line-height: 18px;
}
#respond .required {
	color: #ff4b33;
	font-weight: bold;
}
#respond label {
	color: #888;
	font-size: 12px;
}
#respond input {
	margin: 0 0 9px;
	width: 98%;
}
#respond textarea {
	width: 98%;
}
#respond .form-allowed-tags {
	color: #888;
	font-size: 12px;
	line-height: 18px;
}
#respond .form-allowed-tags code {
	font-size: 11px;
}
#respond .form-submit {
	margin: 12px 0;
}
#respond .form-submit input {
	font-size: 14px;
	width: auto;
}


/* =Widget Areas
-------------------------------------------------------------- */

.widget-area ul {
	list-style: none;
	margin-left: 0;
}
.widget-area ul ul {
	list-style: square;
	margin-left: 1.3em;
}
.widget_search #s {/* This keeps the search inputs in line */
	width: 60%;
}
.widget_search label {
	display: none;
}
.widget-container {
	margin: 0 0 18px 0;
}
.widget-title {
	color: #222;
	font-weight: bold;
}
.widget-area a:link,
.widget-area a:visited {
	text-decoration: none;
}
.widget-area a:active,
.widget-area a:hover {
	text-decoration: underline;
}
.widget-area .entry-meta {
	font-size: 11px;
}
#wp_tag_cloud div {
	line-height: 1.6em;
}
#wp-calendar {
	width: 100%;
}
#wp-calendar caption {
	color: #222;
	font-size: 14px;
	font-weight: bold;
	padding-bottom: 4px;
	text-align: left;
}
#wp-calendar thead {
	font-size: 11px;
}
#wp-calendar thead th {
}
#wp-calendar tbody {
	color: #aaa;
}
#wp-calendar tbody td {
	background: #f5f5f5;
	border: 1px solid #fff;
	padding: 3px 0 2px;
	text-align: center;
}
#wp-calendar tbody .pad {
	background: none;
}
#wp-calendar tfoot #next {
	text-align: right;
}
.widget_rss a.rsswidget {
	color: #000;
}
.widget_rss a.rsswidget:hover {
	color: #ff4b33;
}
.widget_rss .widget-title img {
	width: 11px;
	height: 11px;
}

/* Main sidebars */
#main .widget-area ul {
	margin-left: 0;
	padding: 0 20px 0 0;
}
#main .widget-area ul ul {
	border: none;
	margin-left: 1.3em;
	padding: 0;
}
#primary {
}
#secondary {
}

/* Footer widget areas */
#footer-widget-area {
}


/* =Footer
-------------------------------------------------------------- */

#footer {
	margin-bottom: 20px;
}
#colophon {
	border-top: 4px solid #000;
	margin-top: -4px;
	overflow: hidden;
	padding: 18px 0;
}
#site-info {
	font-weight: bold;
}
#site-info a {
	color: #000;
	text-decoration: none;
}
#site-generator {
	font-style: italic;
	position: relative;
}
#site-generator a {
	#background: url(images/wordpress.png) center left no-repeat;
	color: #666;
	display: inline-block;
	line-height: 16px;
	padding-left: 20px;
	text-decoration: none;
}
#site-generator a:hover {
	text-decoration: underline;
}
img#wpstats {
	display: block;
	margin: 0 auto 10px;
}


/* =Mobile Safari ( iPad, iPhone and iPod Touch )
-------------------------------------------------------------- */

pre {
	-webkit-text-size-adjust: 140%;
}
code {
	-webkit-text-size-adjust: 160%;
}
#access,
.entry-meta,
.entry-utility,
.navigation,
.widget-area {
	-webkit-text-size-adjust: 120%;
}
#site-description {
	-webkit-text-size-adjust: none;
}


/* =Print Style
-------------------------------------------------------------- */

@media print {
	body {
		background: none !important;
	}
	#wrapper {
		clear: both !important;
		display: block !important;
		float: none !important;
		position: relative !important;
	}
	#header {
		border-bottom: 2pt solid #000;
		padding-bottom: 18pt;
	}
	#colophon {
		border-top: 2pt solid #000;
	}
	#site-title,
	#site-description {
		float: none;
		line-height: 1.4em;
		margin: 0;
		padding: 0;
	}
	#site-title {
		font-size: 13pt;
	}
	.entry-content {
		font-size: 14pt;
		line-height: 1.6em;
	}
	.entry-title {
		font-size: 21pt;
	}
	#access,
	#branding img,
	#respond,
	.comment-edit-link,
	.edit-link,
	.navigation,
	.page-link,
	.widget-area {
		display: none !important;
	}
	#container,
	#header,
	#footer {
		margin: 0;
		width: 100%;
	}
	#content,
	.one-column #content {
		margin: 24pt 0 0;
		width: 100%;
	}
	.wp-caption p {
		font-size: 11pt;
	}
	#site-info,
	#site-generator {
		float: none;
		width: auto;
	}
	#colophon {
		width: auto;
	}
	img#wpstats {
		display: none;
	}
	#site-generator a {
		margin: 0;
		padding: 0;
	}
	#entry-author-info {
		border: 1px solid #e7e7e7;
	}
	#main {
		display: inline;
	}
	.home .sticky {
		border: none;
	}
}

@@ path.jpg (base64)
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

