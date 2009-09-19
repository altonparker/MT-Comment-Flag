package CommentFlag::Plugin;
use strict;
use MT::Comment::CommentFlag;
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

sub _hdlr_comment_flag_includes
{
	my $cfg = MT::ConfigMgr->instance();
	my $static_path = $cfg->StaticWebPath() . '/plugins/CommentFlag/';
}

sub _hdlr_comment_flag_link
{
	my ($ctx, $args) = @_;
	
	my $comment = $ctx->stash('comment') or return '';
	
	my $cfg = MT::ConfigMgr->instance();
	my $cgi_path = $cfg->CGIPath();
	my $id = $comment->id();
	my $link = <<LINK;
<a rel="prettyPhoto" href="$cgi_path/plugins/CommentFlag/mt-commentflag.cgi?comment_id=$id">Report</a>
LINK

	return $link;
}

1;
