package MT::App::CommentFlag;

use strict;
use base qw(MT::App);

sub init {
	my $app = shift;
	$app->SUPER::init(@_) or return;
	$app->{template_dir} = 'feeds';
	$app->{is_admin}     = 1;
	$app->add_methods(
		show_dialog => \&show_dialog
	);
	$app->{default_mode} = 'show_dialog';

	$app;
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
	my %cookies = %{ $app->cookies() };
	
	use MT::ObjectTag;
	use MT::Tag;
	
	my @tags = MT::Tag->load(undef, {join => MT::ObjectTag->join_on('tag_id', 
				{object_datasource => 'commentflag', object_id => $comment_id })
			});
	MT->log({message => "Loaded $#tags"});
	
	my $params = {};
	
	return $app->build_page($template, $params);
}

1;

