package Automake::Diagnostic;

use strict;
use warnings;
use 5.006;

use Automake::Boolean;
use Automake::Colors;

use constant {
	D_WARN_SUBDIR => "invalid-subdir",
	D_WARN_PROCFAILED => "procfailed",
	D_WARN_EXTRA_TOKENS => "extra-tokens",
};

use Exporter 'import';
our @EXPORT = qw(
	print_source
	print_warning
	print_error
	print_summary
	set_warning
	set_werror
	is_warning_enabled

	D_WARN_SUBDIR
	D_WARN_PROCFAILED
	D_WARN_EXTRA_TOKENS

	%WERROR_WARNINGS
	@VALID_WARNINGS
	%ENABLED_WARNINGS

	$DIAG_WARN_COUNT
	$DIAG_ERROR_COUNT
);

our $DIAG_WARN_COUNT = 0;
our $DIAG_ERROR_COUNT = 0;

our @VALID_WARNINGS = (
    D_WARN_SUBDIR,
    D_WARN_PROCFAILED,
    D_WARN_EXTRA_TOKENS,
);

our %ENABLED_WARNINGS = map { $_ => true } @VALID_WARNINGS;
our %WERROR_WARNINGS;

sub set_werror
{
	my ($val) = @_;

	if ($val eq 0) {
		%WERROR_WARNINGS = {};
	}
	elsif ($val eq true) {
		%WERROR_WARNINGS = %ENABLED_WARNINGS;
	}
	else {
		$WERROR_WARNINGS{$val} = true;
	}
}

sub set_warning
{
	my ($wname, $enable) = @_;
	$ENABLED_WARNINGS{$wname} = $enable;
}

sub is_warning_enabled
{
	my ($wname) = @_;
	return exists $ENABLED_WARNINGS{$wname} && $ENABLED_WARNINGS{$wname};
}

sub highlight
{
	my ($line) = @_;
	$line =~ s/(if|else|endif)/$BLUE$BOLD$1$RESET/g;
	$line =~ s/(\s+[@\-\+])/$YELLOW$1$RESET/g;
	$line =~ s/((\$[\(\{])([A-Za-z0-9\-_:=~]+)([\)\}]))/$BLUE$2$RESET$GRAY$3$BLUE$4$RESET/g;
	return $line;
}

sub print_source
{
	my ($ln_col, $color, $lines) = @_;
	my $count = scalar @$lines;
	my $iters = $count < 3 ? $count : 3;
    my @splitted = split (":", $ln_col);
    my $loc = +$splitted[0];

	for (my $i = 0; $i < $iters; $i++) {
		my $ln_num_color = $i == $iters - 1 ? $color : $GRAY;
		my $line = @{$lines}[$i];

		$line =~ s/\n+$//g;
		$line =~ s/\t+/    /g;

		@{$lines}[$i] = $line;
		printf STDERR "${ln_num_color}%4d |${RESET} %s\n", $loc - $iters + $i + 1, highlight ($line);
	}

	my $maxlen = (length (@{$lines}[$iters - 1]) - 1);

	if ($maxlen < 0) {
		$maxlen = 0;
	}

	printf STDERR "     ${color}|${RESET} ${color}^" . ("~" x $maxlen) . "${RESET}\n";
}

sub print_warning
{
	my ($message, $flag, $file, $loc, $lines) = @_;

	if ($flag && $WERROR_WARNINGS{$flag}) {
		print_error ($message, $flag, $file, $loc, $lines);
		return;
	}

	if ($flag && !is_warning_enabled ($flag)) {
		return;
	}

	printf STDERR "${BOLD}${WHITE}%s:%s: ${BOLD}${MAGENTA}warning:${RESET} %s " . ($flag ne "" ? "[${BOLD}${MAGENTA}-W%s${RESET}]" : "") . "\n", $file, $loc, $message, $flag;
    print_source ($loc, "${BOLD}${MAGENTA}", $lines);
	$DIAG_WARN_COUNT++;
}

sub print_error
{
	my ($message, $flag, $file, $loc, $lines) = @_;

	if ($flag && !is_warning_enabled ($flag)) {
		return;
	}

	printf STDERR "${BOLD}${WHITE}%s:%s: ${BOLD}${RED}error:${RESET} %s " . ($flag ne "" ? "[${BOLD}${RED}-Werror=%s${RESET}]" : "%0s") . "\n", $file, $loc, $message, $flag;
	print_source ($loc, "${BOLD}${RED}", $lines);
	$DIAG_ERROR_COUNT++;
}

sub print_summary
{
	if ($DIAG_ERROR_COUNT > 0) {
		printf STDERR "$BOLD%d error%s $RESET", $DIAG_ERROR_COUNT, $DIAG_ERROR_COUNT == 1 ? "" : "s";
	}

	if ($DIAG_WARN_COUNT > 0) {
		printf STDERR "$BOLD%d warning%s $RESET", $DIAG_WARN_COUNT, $DIAG_WARN_COUNT == 1 ? "" : "s";
	}

	if ($DIAG_ERROR_COUNT > 0 || $DIAG_WARN_COUNT > 0) {
		print STDERR "${BOLD}generated.\n$RESET";
	}
}

1;
