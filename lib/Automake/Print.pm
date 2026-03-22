package Automake::Print;

use strict;
use warnings;
use 5.006;

use Exporter 'import';
our @EXPORT = qw(
	println
	pr_err
	pr_msg
);

use Automake::Args;
use Automake::Colors;

sub println
{
	my ($message) = @_;
	print $message . "\n";
}

sub pr_msg
{
	my ($message) = @_;
	print STDOUT "${WHITE}${BOLD}$ARGV_0:${RESET} $message\n";
}

sub pr_err
{
	my ($message) = @_;
	print STDERR "${WHITE}${BOLD}$ARGV_0:${RESET} ${RED}${BOLD}error:${RESET} $message\n";
}

1;
