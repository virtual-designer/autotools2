package Automake::Generate;

use strict;
use warnings;
use 5.006;

use File::Basename;

use Automake::Boolean;
use Automake::Diagnostic;

use Exporter 'import';
our @EXPORT = qw(gen_template);

use constant {
    BUF_TOP => 0,
    BUF_INIT => 1,
    BUF_VARS => 2,
    BUF_PREP => 3,
    BUF_BODY => 4,
    BUF_USER => 5,
    BUF_END => 6,
    BUF_FINAL => 7,
    MAX_BUF_COUNT => 8,
};

sub gen_template
{
    my ($wd, $input_am_base, $output_in_base, $am_files) = @_;
    my $input_am = "$wd/$input_am_base";
    my $output_in = "$wd/$output_in_base";
    my @buffers;
    my $next_dirs = [];
    my $warnings = [];
    my $errors = [];

    for (my $i = 0; $i < MAX_BUF_COUNT; $i++) {
        $buffers[$i] = "";
    }

    my @am_files_first;
    my @am_files_last;

    foreach my $am_file (@{$am_files}) {
        my $name = basename ($am_file);
        $name =~ s/-[A-Za-z0-9-_]+\.am$//g;
        my $priority = +$name;

        if ($priority < 50) {
            push @am_files_first, $am_file;
        }
        else {
            push @am_files_last, $am_file;
        }
    }

    foreach my $am_file (@am_files_first) {
        my $am_fh;

        if (!open ($am_fh, '<', $am_file)) {
            return ($warnings, $errors, $next_dirs, false, "$am_file: $!");
        }

        my $contents = do { local $/; <$am_fh>; };
        $buffers[BUF_PREP] .= $contents . "\n";
        close ($am_fh);
    }

    my $input_fh;

    if (!open ($input_fh, '<', $input_am)) {
        return ($warnings, $errors, $next_dirs, false, "$input_am: $!");
    }

    my $ln_num = 1;
    my $last3lines = [];

    while (my $line = <$input_fh>) {
        chomp ($line);

        if (scalar (@$last3lines) >= 3) {
            shift (@$last3lines);
        }

        push @$last3lines, $line;
        my @last3lines_copy = @$last3lines;

        process_line ($ln_num++, $line, \@buffers, $next_dirs, $input_am_base,
                      $warnings, $errors, \@last3lines_copy);
    }

    close ($input_fh);

    foreach my $am_file (@am_files_last) {
        my $am_fh;

        if (!open ($am_fh, '<', $am_file)) {
            return ($warnings, $errors, $next_dirs, false, "$am_file: $!");
        }

        my $contents = do { local $/; <$am_fh>; };
        $buffers[BUF_FINAL] .= $contents . "\n";
        close ($am_fh);
    }

    my $output_fh;

    if (!open ($output_fh, '+>', $output_in)) {
        return ($warnings, $errors, $next_dirs, false, "$output_in: $!");
    }

    foreach my $buffer (@buffers) {
        if (!$buffer) {
            next;
        }

        print $output_fh ($buffer . "\n");
    }

    close ($output_fh);
    return ($warnings, $errors, $next_dirs, true, "");
}

sub process_line
{
    my ($ln_num, $line, $buffers_ref, $next_dirs,
        $input_am_base, $warnings, $errors, $last3lines) = @_;
    my $orig_line = $line;
    $line =~ s/^\s+|\s+$//g;

    if ($line =~ /^all-local:/) {
        @{$buffers_ref}[BUF_USER] .= "all-am: all-local\n";
        @{$buffers_ref}[BUF_USER] .= ".PHONY: all-local\n";
    }
    elsif ($line =~ /^clean-local:/) {
        @{$buffers_ref}[BUF_USER] .= "clean-am: clean-local\n";
        @{$buffers_ref}[BUF_USER] .= ".PHONY: clean-local\n";
    }
    elsif ($line =~ /^SUBDIRS *=/) {
        my $subdirs = $line;
        $subdirs =~ s/^SUBDIRS *= *//g;
        my @dirlist = split (/\s+/, $subdirs);

        foreach my $subdir (@dirlist) {
            if (-f "$subdir/$input_am_base") {
                push @$next_dirs, [$ln_num, 1, $subdir];
                next;
            }

            push @$warnings, [$ln_num, 1, D_WARN_SUBDIR, "Subdirectory '$subdir' does not exist or does not contain a $input_am_base", $last3lines];
        }
    }

    @{$buffers_ref}[BUF_USER] .= $orig_line . "\n";
}

1;
