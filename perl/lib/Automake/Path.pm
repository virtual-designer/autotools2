package Automake::Path;

use strict;
use warnings;
use 5.006;

use Exporter 'import';
our @EXPORT = qw(
	scandir_recursive
);

sub scandir_recursive
{
	my ($dir, $list_ref) = @_;
	$list_ref = defined $list_ref ? $list_ref : [];
		
	my $dh;
	
	if (!opendir ($dh, $dir)) {
		return undef;
	}
	
	while (my $entry = readdir ($dh)) {
		next if $entry eq "." || $entry eq "..";
		my $fullpath = "$dir/$entry";
		
		if (-d $fullpath) {
			my $ret = scandir_recursive ($fullpath, $list_ref);
			
			if (!defined $ret) {
				my $e = $!;
				closedir ($dh);
				$! = $e;
				return undef;
			}
		}
		
		push @{$list_ref}, $fullpath;
	}
	
	closedir ($dh);
	return $list_ref;
}

1;
