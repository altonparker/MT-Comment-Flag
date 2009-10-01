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

1;
