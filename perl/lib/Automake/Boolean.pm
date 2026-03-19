package Automake::Boolean;

use strict;
use warnings;
use 5.006;

use parent qw(Exporter);

use constant {
	true => 1,
	false => 0	
};

our @EXPORT = qw(true false);

1;
