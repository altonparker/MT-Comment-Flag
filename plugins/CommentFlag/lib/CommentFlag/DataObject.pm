package CommentFlag::DataObject;

use strict;
use MT::Tag;
use base qw(MT::Object MT::Taggable);

__PACKAGE__->install_properties({
	column_defs => {
		id			=>	'integer autoincrement',
		comment_id		=>	'integer not null',
		reporter_name		=>	'string(64)',
		reporter_email		=>	'string(64)',
		reporter_id		=>	'integer not null',
		explanation		=>	'text'
	}, datasource => 'comment_flag',
	primary_key => 'id',
	audit => 1
});

1;

