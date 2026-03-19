package Automake::Args;

use strict;
use warnings;
use 5.006;

use File::Basename;
use Automake::Boolean;
use Automake::Colors;

use Exporter 'import';
our @EXPORT = qw(
	getopt_long

	ARG_NONE
	ARG_OPTIONAL
	ARG_REQUIRED

	OPT_FLAG_MULTI_ARGS

	ARGV_0
	$ARGV_0
);

use constant {
	ARG_NONE     => 0,
	ARG_OPTIONAL => 1,
	ARG_REQUIRED => 2,

	ARGV_0 => $0 =~ /^\// ? basename($0) : $0
};

use constant {
	OPT_FLAG_MULTI_ARGS => 1
};

our $ARGV_0 = ARGV_0;
my $me = ARGV_0;

sub getopt_long
{
	my ($long_options_ref, $long_only, $custom_opt_callback, $argv_ref) = @_;
	my @long_options = @$long_options_ref;
	my @argv = defined $argv_ref ? @$argv_ref : @ARGV;
	my %optmap;

    foreach my $optentry (@long_options) {
    	my $name = $optentry->{"name"};
    	my $shortopts = $optentry->{"short"};

       	$optmap{$name} = $optentry;

    	foreach my $shortopt ($shortopts) {
    		$optmap{$shortopt} = $optentry;
    	}
    }

    my @outargs;
    my %optargs;

    while (@argv) {
    	my $arg = shift @argv;

    	if ($arg !~ /^-/) {
    		push @outargs, $arg;
			next;
       	}

    	my $is_actually_short = $arg !~ /^--/;
    	my $is_short = !$long_only && $is_actually_short;
		my $opt = substr ($arg, $is_actually_short ? 1 : 2);

		foreach my $c (split //, $opt) {
			my $optarg = true;
			my $opt_processed = false;

			if (!$is_short) {
				$c = $opt;

				if ($c =~ /=/) {
					my $eqpos = index ($opt, "=");
					$c = substr ($opt, 0, $eqpos);
					$optarg = substr ($opt, $eqpos + 1);
					$opt_processed = true;
				}
			}

			my $optentry = $optmap{$c};

			if (!defined $optentry) {
				if ($custom_opt_callback) {
					my $ret = $custom_opt_callback->($is_actually_short, $c, $opt_processed ? $optarg : "", \@argv);

					if ($ret) {
						last;
					}
				}

				print STDERR "$BOLD$me:$RESET Invalid option '-" . ($is_actually_short ? "" : "-") . "$c'\n";
				print STDERR "$BOLD$me:$RESET Try '$me --help' for more information.\n";
				exit 1;
			}

			my $optargmode = $optentry->{"argument"};

			if ($optargmode != ARG_NONE && !$opt_processed) {
				$optarg = !@argv || $argv[0] =~ /^-/ ? "" : shift @argv;
			}

			if ($optargmode == ARG_NONE && $opt_processed) {
				print STDERR "$BOLD$me:$RESET Option '-" . ($is_actually_short ? "" : "-") . "$c' does not accept an argument\n";
				print STDERR "$BOLD$me:$RESET Try '$me --help' for more information.\n";
				exit 1;
			}

			if ($optargmode == ARG_REQUIRED && !$optarg) {
				print STDERR "$BOLD$me:$RESET Option '-" . ($is_actually_short ? "" : "-") . "$c' requires an argument\n";
				print STDERR "$BOLD$me:$RESET Try '$me --help' for more information.\n";
				exit 1;
			}

			if (exists $optentry->{"flags"} && $optentry->{"flags"} & OPT_FLAG_MULTI_ARGS) {
				my $name = $optentry->{"name"};
				$optargs{$name} ||= [];
				push @{$optargs{$name}}, $optarg;
			}
			else {
		   		$optargs{$optentry->{"name"}} = $optarg;
		   	}

			last if !$is_short;
		}
    }

    return (\@outargs, \%optargs);
}

1;
