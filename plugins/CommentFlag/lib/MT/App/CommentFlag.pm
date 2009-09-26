package MT::App::CommentFlag;

use strict;
use base qw(MT::App);

sub init {
	my $app = shift;
	$app->SUPER::init(@_) or return;
	$app->{template_dir} = 'feeds';
	$app->{is_admin}     = 1;
	$app->add_methods(
		show_dialog => \&show_dialog,
		do_login       => \&do_login,
		);
	$app->{default_mode} = 'show_dialog';

	$app;
}

sub do_login
{
	my $app = shift;
	my $username = $app->param('username');
	my $password = $app->param('password');
	
	use MT::Auth;
	use MT::Auth::MT;
	
	#$app->{username} = $username;
	#$app->{password} = $password;
	
	my $ctx = MT::Auth::MT->fetch_credentials({app => $app });
	$ctx->{blog_id} = $app->param('blog_id');
	my $result = MT::Auth->validate_credentials($ctx);
	if (   ( MT::Auth::NEW_LOGIN() == $result )
	        || ( MT::Auth::NEW_USER() == $result )
        || ( MT::Auth::SUCCESS() == $result ) )
	{
		#die("Blarg!");
		$app->redirect('http://www.codemonkeyramblings.com/mt/plugins/CommentFlag/mt-comment-flag.cgi?blog_id=2')
	}
}

sub init_request {
	my $app = shift;
	$app->SUPER::init_request(@_);
	$app->{requires_login} = 1;
}

sub file_report
{
	my $app = shift;
}

sub show_dialog
{
	my $app = shift;
	my $plugin = MT->component('CommentFlag');
	my $template = $plugin->load_tmpl('report_dialog.tmpl');
	my $comment_id = $app->param('comment_id');
	
	my $blog_id = $app->param('blog_id');
	my $req_auth = $plugin->get_config_value('comment_flag_require_authentication', "blog:$blog_id");
	
	$app->{requires_login} = $req_auth;
	
	my $tagstr = $plugin->get_config_value('comment_flag_tags', "blog:$blog_id");
	my @tagnames = split(/,[\s*]/, $tagstr);
	
	my @reasons;
	
	foreach my $tag (@tagnames)
	{
		my $reason = { reason => $tag };
		push (@reasons, $reason);
	}
	
	my $params = {};
	$params->{reasons} = \@reasons;
	$params->{must_be_logged_in} = $req_auth;
	$params->{user_is_anonymous} = 0;
	
	if (defined ($app->user))
	{
		$params->{registered_name} = $app->user->name;
		$params->{registered_email} = $app->user->email;
	}
	
	return $app->build_page($template, $params);
}

1;

