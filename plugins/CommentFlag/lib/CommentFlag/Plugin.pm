package CommentFlag::Plugin;
use strict;
use CommentFlag::DataObject;
use MT::ConfigMgr;

sub _comment_post_remove
{
	my ($cb, $comment) = @_;
	
	MT::Comment::CommentFlag->remove({comment_id => $comment->id()});
}

sub _comment_post_remove_all
{
	my ($cb) = @_;
	
}

sub _comment_flag_quick_filter
{
	my ( $terms, $args ) = @_;
	my $join = CommentFlag::DataObject->join_on('comment_id', {});
	
	$args->{join} = $join;
	$args->{unique} = 1;
}


sub _hdlr_comment_flag_includes
{
	my $cfg = MT::ConfigMgr->instance();
	my $static_path = $cfg->StaticWebPath() . '/plugins/CommentFlag/';
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
	my $url = _hdlr_comment_flag_url($ctx, $args);
	
	
	my $link = <<LINK;
<a rel="prettyPhoto" href="$url?comment_id=$id">Report</a>
LINK

	return $link;
}

1;
