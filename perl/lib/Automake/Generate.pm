package Automake::Generate;

use strict;
use warnings;
use 5.006;

use File::Basename;
use File::Spec;

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
    my ($wd, $root_wd, $input_am_base, $output_in_base, $am_files) = @_;
    my $input_am = "$wd/$input_am_base";
    my $output_in = "$wd/$output_in_base";

    $input_am =~ s/^\.\/+//g;
    $output_in =~ s/^\.\/+//g;

    my @buffers;
    my $next_dirs = [];
    my $warnings = [];
    my $errors = [];
    my %context = (
        warnings => $warnings,
        errors => $errors,
        buffers => \@buffers,
        next_dirs => $next_dirs,
        input_am_base => $input_am_base,
        sysdirs => {},
        program_vars => {},
        wd => $wd,
        root_wd => $root_wd,
    );

    for (my $i = 0; $i < MAX_BUF_COUNT; $i++) {
        $buffers[$i] = "";
    }

    prepare ($input_am, \%context);

    my @am_files_first;
    my @am_files_last;
    my @am_files_all;

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

    push @am_files_all, @am_files_first;
    push @am_files_all, $input_am;
    push @am_files_all, @am_files_last;

    foreach my $am_file (@am_files_all) {
        my $am_fh;

        if (!open ($am_fh, '<', $am_file)) {
            return ($warnings, $errors, $next_dirs, false, "$am_file: $!");
        }

        my $ln_num = 1;
        my $last3lines = [];

        while (my $line = <$am_fh>) {
            chomp ($line);

            if (scalar (@$last3lines) >= 3) {
                shift (@$last3lines);
            }

            push @$last3lines, $line;
            my @last3lines_copy = @$last3lines;

            process_line ($ln_num++, $line, $am_file, \@last3lines_copy, \%context);
        }

        close ($am_fh);
    }

    finalize ($input_am, \%context);

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
    my ($ln_num, $line, $input_am, $last3lines, $context) = @_;
    my $orig_line = $line;
    my $wd = %$context{wd};
    my $main_input_am_base = %$context{input_am_base};
    my $buffers_ref = %$context{buffers};
    my $next_dirs = %$context{next_dirs};
    my $warnings = %$context{warnings};
    my $errors = %$context{errors};

    $line =~ s/^\s+|\s+$//g;

    if ($line =~ /^all-local:/) {
        @{$buffers_ref}[BUF_USER] .= "all-am: all-local\n";
        @{$buffers_ref}[BUF_USER] .= ".PHONY: all-local\n";
    }
    elsif ($line =~ /^clean-local:/) {
        @{$buffers_ref}[BUF_USER] .= "clean-am: clean-local\n";
        @{$buffers_ref}[BUF_USER] .= ".PHONY: clean-local\n";
    }
    elsif ($line =~ /^SUBDIRS[ \t]*=/) {
        my $subdirs = $line;
        $subdirs =~ s/^SUBDIRS[ \t]*= *//g;
        my @dirlist = split (/\s+/, $subdirs);

        foreach my $subdir (@dirlist) {
            if (-f "$wd/$subdir/$main_input_am_base") {
                push @$next_dirs, [$ln_num, 1, $subdir];
                next;
            }

            push @$warnings, [$ln_num, 1, $input_am, D_WARN_SUBDIR,
                              "Subdirectory '$subdir' does not exist or does not contain a $main_input_am_base",
                              $last3lines];
        }
    }
    elsif ($line =~ /^([a-z0-9]+)dir[ \t]*=[ \t]*(.*)/) {
        my $dirname = $1;
        my $path = $2;
        my $dirs = %$context{sysdirs};
        $dirs->{$dirname} = $path;
    }
    elsif ($line =~ /^([a-z0-9]+)_PROGRAMS[ \t]*=[ \t]*(.*)$/) {
        my $dirs = $context->{sysdirs};

        if (!exists $dirs->{$1}) {
            push @$warnings, [$ln_num, 1, $input_am, D_WARN_UNDEFINED_SYSDIR,
                              "${1}dir is not defined", $last3lines];
        }

        $context->{program_vars}->{$1} = (exists $context->{program_vars}->{$1} ? $context->{program_vars}->{$1} : "") . $2;
    }
    elsif ($line =~ /^([a-zA-Z0-9-_]+)_SOURCES[ \t]*=/) {
        my $program = $1;

        @{$buffers_ref}[BUF_USER] .= $orig_line . "\n";
        @{$buffers_ref}[BUF_USER] .= "${program}_OBJECTS0 = \$(${program}_SOURCES:.c=.o)\n";
        @{$buffers_ref}[BUF_USER] .= "${program}_OBJECTS1 = \$(${program}_OBJECTS0:.cxx=.o)\n";
        @{$buffers_ref}[BUF_USER] .= "${program}_OBJECTS2 = \$(${program}_OBJECTS1:.cpp=.o)\n";
        @{$buffers_ref}[BUF_USER] .= "${program}_OBJECTS = \$(${program}_OBJECTS2:.cc=.o)\n\n";

        return;
    }

    @{$buffers_ref}[BUF_USER] .= $orig_line . "\n";
}

sub prepare
{
    my ($am_file, $context) = @_;
    my $buffers = %$context{buffers};
    my $rel = File::Spec->abs2rel ($context->{wd}, $context->{root_wd});
    my $rev_rel = File::Spec->abs2rel ($context->{root_wd}, $context->{wd});
    my $orig_rel = $rel;
    $rel = $rel eq "." ? "" : "/$rel";

    @$buffers[BUF_INIT] .= "# This file was generated by automake2.\n";
    @$buffers[BUF_INIT] .= "# DO NOT EDIT THIS FILE MANUALLY.\n\n";
    @$buffers[BUF_INIT] .= "AUTOMAKE = $0\n\n";
    @$buffers[BUF_INIT] .= "top_builddir = $rev_rel\n";
    @$buffers[BUF_INIT] .= "subdir = $orig_rel\n";
    @$buffers[BUF_INIT] .= "srcdir = \$(top_srcdir)$rel\n";
    @$buffers[BUF_INIT] .= "builddir = \$(top_builddir)$rel\n";
    @$buffers[BUF_INIT] .= "\n";
}

sub finalize
{
    my ($am_file, $context) = @_;
    my $buffers = %$context{buffers};
    @$buffers[BUF_END] .= "all-am: ";

    foreach my $program_var (keys %{%$context{program_vars}}) {
        @$buffers[BUF_END] .= "\$(${program_var}_PROGRAMS)";

        my $programs = %{%$context{program_vars}}{$program_var};
        my @programs_list = split (/\s+/, $programs);

        foreach my $program (@programs_list) {
            @{$buffers}[BUF_USER] .= "${program}: \$(${program}_OBJECTS)\n";
            @{$buffers}[BUF_USER] .= "\t\$(AM_V_CCLD) \$(AM_LDFLAGS) \$(LDFLAGS) \$(${program}_LDFLAGS) -o \$@ \$(${program}_OBJECTS) \$(${program}_LDADD) \$(LDADD) \$(LDLIBS) \$(LIBS)\n\n";
            @{$buffers}[BUF_USER] .= "am_v_rm_prog_${program}_0 = \@echo \"  RM      ${program}\";\n";
            @{$buffers}[BUF_USER] .= "am_v_rm_prog_${program}_1 = \n";

            @{$buffers}[BUF_USER] .= "#+\$if _AM_SILENT_RULES\n";
            @{$buffers}[BUF_USER] .= "am_v_rm_prog_${program}_ = \$(am_v_rm_prog_${program}_0)\n";
            @{$buffers}[BUF_USER] .= "#+\$endif\n";

            @{$buffers}[BUF_USER] .= "#+\$if ! _AM_SILENT_RULES\n";
            @{$buffers}[BUF_USER] .= "am_v_rm_prog_${program}_ = \$(am_v_rm_prog_${program}_1)\n";
            @{$buffers}[BUF_USER] .= "#+\$endif\n";

            @{$buffers}[BUF_USER] .= "AM_V_RM_PROG_${program} = \$(am_v_rm_prog_${program}_\$(V))\$(RM)\n\n";

            @{$buffers}[BUF_USER] .= "clean-am: clean-${program}\n\n";

            @{$buffers}[BUF_USER] .= "clean-${program}:\n";
            @{$buffers}[BUF_USER] .= "\t\$(AM_V_RM_PROG_${program}) ${program} \$(${program}_OBJECTS) && \$(RM) -r ${program}.dSYM\n\n";
        }
    }

    @$buffers[BUF_END] .= "\n";
}

1;
