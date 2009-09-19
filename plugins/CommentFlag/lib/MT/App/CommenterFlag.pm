package MT::App::CommenterFlag;

use strict;
use base (MT::App);

sub init {
	my $app = shift;
	$app->SUPER::init(@_) or return;
	$app->{template_dir} = 'feeds';
	$app->{is_admin}     = 1;
	$app->add_methods(

	);

	$app;
}

sub init_request {
	my $app = shift;
	$app->SUPER::init_request(@_);
	$app->{requires_login} = 1;
}

sub flag_comment
{
	my $app = shift;
	my $comment_id = $app->param('comment_id');
}

1;

