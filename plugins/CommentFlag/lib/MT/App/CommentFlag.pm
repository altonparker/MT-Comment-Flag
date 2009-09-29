package MT::App::CommentFlag;

use strict;
use base qw(MT::App);

sub init {
	my $app = shift;
	$app->SUPER::init(@_) or return;
	$app->{template_dir} = 'feeds';
	$app->{is_admin}     = 1;
	$app->add_methods(
		show_dialog 	=> \&show_dialog,
		do_login       	=> \&do_login,
		file_report	=> \&file_report
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
	my $comment_id = $app->param('comment_id');
	my $reason = $app->param('reason');
	my $remarks = $app->param('remarks');
	my $email = $app->param('email');
	my $name = $app->param('name');
	my $registered_id = $app->param('registered_id') || -1;

	use MT::Tag;
	use CommentFlag::DataObject;
	
	my $errors = {};
	$errors->{no_comment_id} = 1 unless $comment_id > 0;
	$errors->{no_reason} = 1 unless $reason ne ''; # ($reason ne '' ? 0 : 1);
	$errors->{no_remarks} = 1 unless $remarks ne ''; #($remarks ne '' ? 0 : 1);
	$errors->{no_email} = 1 unless ($email ne '' or $registered_id > 0); # ($email ne '' or $registered_id > 0 ? 0 : 1);
	$errors->{no_name} = 1 unless ($name ne '' or $registered_id > 0); # ($name ne '' or $registered_id > 0 ? 0 : 1);
	
	if (CommentFlag::DataObject->exist({comment_id => $comment_id}))
	{
		$app->param('is_a_duplicate', 1);
		return $app->show_dialog;
	}
	
	my @keys = keys($#errors);
	if ( ( $#keys+1 ) > 0 )
	{
		foreach (keys (%$errors) )
		{
			$app->param ($_, $errors->{$_});
		}
		return $app->show_dialog;
	}

	my $tag = MT::Tag->exist({name => $reason});
	if (!$tag)
	{
		$tag = MT::Tag->new();
		$tag->name($reason);
		$tag->save();
	}
	
	my $flag = CommentFlag::DataObject->new();
	$flag->comment_id($comment_id);
	unless($registered_id > -1)
	{
		$flag->reporter_name($name);
		$flag->reporter_email($email);
	}
	$flag->reporter_id($registered_id);
	$flag->explanation($remarks);
	$flag->add_tags($reason);
	$flag->save() or die ($flag->errstr);
	
	$app->param('flag_successful', 1);
	
	return $app->show_dialog;
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
	$params->{comment_id} = $comment_id;
	
	foreach my $key ( keys(%{ $app->param })  )
	{
		if (($key =~ /^no[t]?/) or ($key =~ /^is/))
		{
			$params->{$key} = $app->param($key);
		}
	}
	
	if (defined ($app->user))
	{
		$params->{registered_id} = $app->user->id;
	}
	
	return $app->build_page($template, $params);
}

1;

