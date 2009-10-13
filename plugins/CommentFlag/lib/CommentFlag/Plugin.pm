package CommentFlag::Plugin;
use strict;
use CommentFlag::DataObject;
use MT::ConfigMgr;

sub _comment_post_remove
{
	my ($cb, $comment) = @_;
	
	CommentFlag::DataObject->remove({comment_id => $comment->id()});
}

sub _comment_flag_quick_filter
{
	my ( $terms, $args ) = @_;
	my $join = CommentFlag::DataObject->join_on('comment_id', {});
	
	$args->{join} = $join;
	$args->{unique} = 1;
}

sub _comment_unflag_page_action {
	my ($app) = @_;
	$app->validate_magic or return;
	
	my $id = $app->param('id');
	CommentFlag::DataObject->remove({comment_id => $id});
	$app->redirect(
		$app->uri(
			mode => 'list_comments',
			args   => {
				filter_key => 'comment_flag',
				blog_id => $app->blog->id,
			}
		)
	);

}

sub _hdlr_comment_flag_includes
{
	my $cfg = MT::ConfigMgr->instance();
	my $static_path = $cfg->StaticWebPath() . '/plugins/CommentFlag/';
}

sub _hdlr_comment_flag_includes
{
	my ($ctx, $args) = @_;
	my $cfg = MT::ConfigMgr->instance();
	my $static_path = $cfg->StaticWebPath();
	
	my $script_left = "<script type=\"text/javascript\" src=\"";
	my $script_right = "\"></script>";
	
	my $retVal = '';
	$retVal .= "$script_left$static_path/plugins/CommentFlag/js/jquery-1.3.2.min.js$script_right\n" if $args->{add_jquery};
	$retVal .= "$script_left$static_path/plugins/CommentFlag/js/jquery.prettyPhoto.js$script_right\n";
	$retVal .= "<link rel=\"stylesheet\" type=\"text/css\" href=\"$static_path/plugins/CommentFlag/css/prettyPhoto.css\"/>\n";
	
	return $retVal;
}

sub _hdlr_comment_flag_javascript
{
	my $js = <<JAVASCRIPT;

<script type="text/javascript">
loginIntervalID = 0;

function CheckPopupClose() {
	var currentURL = new Array();
	currentURL = window.location.href.split('#');

	if ( window.location.hash == "#close-pp-delay" ) {
		window.location.href = currentURL[0] + "#";
		clearInterval( loginIntervalID );
		setTimeout( '\$.prettyPhoto.close()', 6000);

	} else if ( window.location.hash == "#close-pp" ) {
		window.location.href = currentURL[0] + "#";
		\$.prettyPhoto.close();
		clearInterval( loginIntervalID );

	} else if ( window.location.hash == "#open-reg" ) {
		\$.prettyPhoto.close();
		clearInterval( loginIntervalID );
	}

	return false;
}

\$(document).ready(function() {
	\$("a[rel^='prettyPhoto']").mouseup(function () {
		clearInterval( loginIntervalID );
		var currentURL = new Array();
		currentURL = window.location.href.split('#');
		window.location.href = currentURL[0] + "#";
		loginIntervalID = setInterval ("CheckPopupClose()", 500);
	});
	\$("a[rel^='prettyPhoto']").prettyPhoto(
		{
			showTitle: true,
			callback: function()
			{
				clearInterval( loginIntervalID );
				return false;
			}
		});
});
</script>

JAVASCRIPT

	return $js;
}

sub _hdlr_comment_flag_url
{
	my ($ctx, $args) = @_;
	my $cfg = MT::ConfigMgr->instance();
	my $cgi_path = $cfg->CGIPath();
	
	return "$cgi_path/plugins/CommentFlag/mt-comment-flag.cgi";
}

sub _hdlr_comment_flag_link
{
	my ($ctx, $args) = @_;
	
	my $comment = $ctx->stash('comment') or return '';
	my $id = $comment->id();
	my $blog_id = $comment->blog->id;
	my $url = _hdlr_comment_flag_url($ctx, $args);
	
	
	my $link = <<LINK;
<a rel="prettyPhoto" href="$url?comment_id=$id&blog_id=$blog_id&iframe=true&height=400&width=700">Report</a>
LINK

	return $link;
}

sub _remove_flag_mode
{
	my $app = shift;
	my $comment_id = $app->param('comment_id');
	my $blog_id = $app->param('blog_id') || 0;
	
	require MT::Permission;
	my $perms = MT::Permission->load({blog_id => $blog_id, author_id => $app->user->id });
	
	unless ($perms->can_administer_blog) {
		die("You don't have permission to unflag reported comments.");
	}

	CommentFlag::DataObject->remove({ comment_id => $comment_id });

	$app->redirect(
		$app->uri(
			mode => 'list_comment',
			args => {
				blog_id => $blog_id,
				filter_key => 'comment_flag'
			}
		)
	);
}

sub _edit_comment_callback
{
	my ($cb, $app, $src) = @_;

	my $flag = $app->model('commentflag')->load({ comment_id => $app->param('id') });

	return '' if !$flag;

	my @tags = $flag->tags;
	my $label = $tags[0];
	my $comment_id = $app->param('id');
	my $remove_uri = $app->uri(
		mode => 'remove_comment_flag',
		args => {
			blog_id => $app->param('blog_id') || 0,
			comment_id => $comment_id
		}
	);

	my $tmpl = <<TMPL;
    <mtapp:setting
        id="flagstuff"
        label="<__trans phrase="Why It Was Reported">"
        content_class="field-content-text"
        hint="<__trans phrase="Why this comment was flagged.">"
        show_hint="0">
        $label &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="$remove_uri">Unflag</a>
    </mtapp:setting>
TMPL
	$$src =~ s/(<mtapp:setting[\s\n]*id="ip")/$tmpl\n$1/;
}

1;
