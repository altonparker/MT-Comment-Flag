package MT::Comment::CommentFlag;
use strict;

use base qw(MT::Object);

__PACKAGE__->install_properties({
	column_defs => {
		id		=>	'integer primary key auto_increment',
		comment_id	=>	'integer not null',
		reporter_id	=>	'integer not null'
	},
	audit => 1,
	primary_key => id,
	datasource => comment_flag
});

sub class_label {
    return MT->translate("Comment Flag");
}

sub class_label_plural {
    return MT->translate("Comment Flags");
}


1;
