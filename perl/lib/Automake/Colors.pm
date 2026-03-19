package Automake::Colors;

use strict;
use warnings;
use 5.006;

use Exporter 'import';
our @EXPORT = qw(
	$WHITE
	$RED
	$GREEN
	$YELLOW
	$BLUE
	$MAGENTA
	$GRAY
	$BOLD
	$RESET
);

our $WHITE = "";
our $RED = "";
our $GREEN = "";
our $YELLOW = "";
our $BLUE = "";
our $MAGENTA = "";
our $GRAY = "";
our $BOLD = "";
our $RESET = "";

if (-t STDOUT && -t STDERR) {
    $WHITE = "\033[38m";
	$RED = "\033[31m";
	$GREEN = "\033[32m";
	$YELLOW = "\033[33m";
	$BLUE = "\033[34m";
	$MAGENTA = "\033[35m";
	$GRAY = "\033[37m";
	$BOLD = "\033[1m";
	$RESET = "\033[0m";
}

1;
