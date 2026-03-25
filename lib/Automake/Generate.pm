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
        input_am => $input_am,
        input_am_base => $input_am_base,
        sysdirs => {},
        program_vars => {},
        lib_vars => {},
        wd => $wd,
        root_wd => $root_wd,
        cond_stack => [],
        am_options => "dist-gz",
        var_index => 0,
        dist_targets => "",
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

    my $ln_num;
    my $last3lines;

    foreach my $am_file (@am_files_all) {
        $ln_num = 1;
        $last3lines = [];

        my $am_fh;

        if (!open ($am_fh, '<', $am_file)) {
            return ($warnings, $errors, $next_dirs, false, "$am_file: $!");
        }

        # TODO: Ensure backslashes at the end of lines are handled

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

        if ($am_file eq $input_am) {
            $buffers[BUF_USER] .= "AM_AUTO_DIST_FILES = " . $context{dist_targets} . "\n\n";
        }
    }

    if (scalar (@$last3lines) >= 3) {
        shift (@$last3lines);
    }

    push @$last3lines, "";
    finalize ($input_am, $ln_num, $last3lines, \%context);

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
    my $cond_stack = %$context{cond_stack};

    $line =~ s/^\s+|\s+$//g;

    my $print_line = $orig_line;

    while ($line =~ /\$\(([A-Za-z_][A-Za-z0-9_]+)\:(([^=]*\|)+[^=]*)+=([^=]*)\)/) {
        my $varname = $1;
        my @exts = split (/\|/, $2);
        my $replace = $4;
        my $str = "";

        foreach my $ext (@exts) {
            my $var_index = ++$context->{var_index};
            $str .= "${varname}_${var_index} = \$(${varname}" . ($var_index - 1 <= 0 ? "" : ("_" . ($var_index - 1))) . ":${ext}=${replace})\n";
        }

        if ($buffers_ref->[BUF_USER]) {
            $buffers_ref->[BUF_USER] =~ s/([^\s:]+:)(?!.*[^\s:]+:)/$str\n$1/sm;
        }
        else {
            $buffers_ref->[BUF_USER] .= $str;
        }

        my $var_index = $context->{var_index}++;
        $line =~ s/\$\(([A-Za-z_][A-Za-z0-9_]+)\:(([^=]*\|)+[^=]*)+=([^=]*)\)/\$(${varname}_${var_index})/;
        $print_line =~ s/\$\(([A-Za-z_][A-Za-z0-9_]+)\:(([^=]*\|)+[^=]*)+=([^=]*)\)/\$(${varname}_${var_index})/;
    }

    if ($line =~ /^(all|clean|distclean|install)-local:/) {
        @{$buffers_ref}[BUF_USER] .= "${1}-am: ${1}-local\n";
        @{$buffers_ref}[BUF_USER] .= ".PHONY: ${1}-local\n";
    }
    elsif ($line =~ /^(all|clean|install)-([a-zA-Z0-9-_]+)-hook:/) {
        my $target = "${2}--am-${1}";
        @{$buffers_ref}[BUF_USER] .= "${target}: ${1}-${2}-hook\n\n";
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
    elsif ($line =~ /^([a-z0-9]+)dir[ \t]*=[ \t]*(.*)$/) {
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

    elsif ($line =~ /^([a-z0-9]+)_LIBRARIES[ \t]*=[ \t]*(.*)$/) {
        my $dirs = $context->{sysdirs};

        if (!exists $dirs->{$1}) {
            push @$warnings, [$ln_num, 1, $input_am, D_WARN_UNDEFINED_SYSDIR,
                              "${1}dir is not defined", $last3lines];
        }

        $context->{lib_vars}->{$1} = (exists $context->{lib_vars}->{$1} ? $context->{lib_vars}->{$1} : "") . $2;
    }
    elsif ($line =~ /^([a-zA-Z0-9-_]+)_SOURCES[ \t]*=[ \t]*(.*)$/) {
        my $program = $1;

        @{$buffers_ref}[BUF_USER] .= $line . "\n";
        @{$buffers_ref}[BUF_USER] .= "${program}_OBJECTS0 = \$(${program}_SOURCES:.c=.o)\n";
        @{$buffers_ref}[BUF_USER] .= "${program}_OBJECTS1 = \$(${program}_OBJECTS0:.cxx=.o)\n";
        @{$buffers_ref}[BUF_USER] .= "${program}_OBJECTS2 = \$(${program}_OBJECTS1:.cpp=.o)\n";
        @{$buffers_ref}[BUF_USER] .= "${program}_OBJECTS = \$(${program}_OBJECTS2:.cc=.o)\n\n";
        @{$buffers_ref}[BUF_VARS] .= "${program}_SOURCES_DIST = $2\n";

        if ($2 =~ /\.(cc|cxx|cpp)/) {
            @{$buffers_ref}[BUF_USER] .= "${program}_LD = \$(AM_V_CXXLD)\n";
        }

        $context->{dist_targets} .= " \$(${program}_SOURCES_DIST)";
        return;
    }
    elsif ($line =~ /^if[ \t]+([A-Za-z0-9_]+)/) {
        my $cond = $1;
        push @$cond_stack, $cond;
        @{$buffers_ref}[BUF_USER] .= "#+\$if $cond\n";
        return;
    }
    elsif ($line =~ /^elif[ \t]+([A-Za-z0-9_]+)/) {
        my $cond = $1;

        if (scalar (@$cond_stack) == 0) {
            push @$errors, [$ln_num, 1, $input_am, D_ERR_INVALID_NESTING,
                            "Invalid nesting of if-directives",
                            $last3lines];
            return;
        }

        pop @$cond_stack;
        push @$cond_stack, $cond;

        @{$buffers_ref}[BUF_USER] .= "#+\$endif\n";
        @{$buffers_ref}[BUF_USER] .= "#+\$if $cond\n";

        return;
    }
    elsif ($line =~ /^else[ \t]*$/) {
        if (scalar (@$cond_stack) == 0) {
            push @$errors, [$ln_num, 1, $input_am, D_ERR_INVALID_NESTING,
                            "Invalid nesting of if-directives",
                            $last3lines];
            return;
        }

        my $cond = @$cond_stack[scalar (@$cond_stack) - 1];
        @{$buffers_ref}[BUF_USER] .= "#+\$endif\n";
        @{$buffers_ref}[BUF_USER] .= "#+\$if ! $cond\n";
        return;
    }
    elsif ($line =~ /^endif[ \t]*$/) {
        if (scalar (@$cond_stack) == 0) {
            push @$errors, [$ln_num, 1, $input_am, D_ERR_INVALID_NESTING,
                            "Invalid nesting of if-directives",
                            $last3lines];
            return;
        }

        pop @$cond_stack;
        @{$buffers_ref}[BUF_USER] .= "#+\$endif\n";
        return;
    }

    @{$buffers_ref}[BUF_USER] .= $print_line . "\n";
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
    @$buffers[BUF_INIT] .= "am_rel_up = " . ($rev_rel eq "." ? "" : "/$rev_rel") . "\n";
    @$buffers[BUF_INIT] .= "am_rel_subdir = $rel\n";
    @$buffers[BUF_INIT] .= "\n";
}

sub finalize
{
    my ($am_file, $ln_num, $last3lines, $context) = @_;
    my $buffers = %$context{buffers};
    my $warnings = %$context{warnings};
    my $errors = %$context{errors};
    my $cond_stack = %$context{cond_stack};

    if (scalar (@$cond_stack) > 0) {
        push @$errors, [$ln_num, 1, $am_file, D_ERR_INVALID_NESTING,
                        "Missing endif one or more directives",
                        $last3lines];
        return;
    }

    @{$buffers}[BUF_USER] .= "AM_AUTOMAKE_OPTIONS = \$(AUTOMAKE_OPTIONS) \$(AUTOMAKE_OPTIONS_ADD) " . $context->{am_options} . "\n\n";

    sub cleanup
    {
        my ($name_raw, $name, $context) = @_;
        my $buffers = %$context{buffers};

        @{$buffers}[BUF_USER] .= "am_v_rm_e_${name}_0 = \@echo \"  RM       ${name_raw}\";\n";
        @{$buffers}[BUF_USER] .= "am_v_rm_e_${name}_1 = \n";

        @{$buffers}[BUF_USER] .= "#+\$if _AM_SILENT_RULES\n";
        @{$buffers}[BUF_USER] .= "am_v_rm_e_${name}_ = \$(am_v_rm_e_${name}_0)\n";
        @{$buffers}[BUF_USER] .= "#+\$endif\n";

        @{$buffers}[BUF_USER] .= "#+\$if ! _AM_SILENT_RULES\n";
        @{$buffers}[BUF_USER] .= "am_v_rm_e_${name}_ = \$(am_v_rm_e_${name}_1)\n";
        @{$buffers}[BUF_USER] .= "#+\$endif\n";

        @{$buffers}[BUF_USER] .= "AM_V_RM_E_${name} = \$(am_v_rm_e_${name}_\$(V))\$(RM)\n\n";

        @{$buffers}[BUF_USER] .= "${name_raw}--am-clean: clean-${name}\n";
        @{$buffers}[BUF_USER] .= "clean-${name}:\n";
        @{$buffers}[BUF_USER] .= "\t\$(AM_V_RM_E_${name}) ${name_raw} \$(${name}_OBJECTS) && \$(RM) -r ${name}.dSYM\n\n";
    }

    foreach my $program_var (keys %{%$context{program_vars}}) {
        @$buffers[BUF_END] .= "all-am: \$(${program_var}_PROGRAMS:=--am-all)\n";

        my $programs = %{%$context{program_vars}}{$program_var};
        my @programs_list = split (/\s+/, $programs);

        foreach my $program_raw (@programs_list) {
            my $program = $program_raw;
            $program =~ s/[\.-\/]/_/g;

            @{$buffers}[BUF_VARS] .= "${program}_LD = \$(AM_V_CCLD)\n";
            @{$buffers}[BUF_VARS] .= "${program}_LINK = \$(${program}_LD) \$(AM_LDFLAGS) \$(LDFLAGS) \$(${program}_LDFLAGS)\n";

            @{$buffers}[BUF_USER] .= "${program_raw}--am-all: ${program_raw}\n";
            @{$buffers}[BUF_USER] .= "${program_raw}: \$(${program}_OBJECTS)\n";
            @{$buffers}[BUF_USER] .= "\t\$(${program}_LINK)  -o \$@ \$(${program}_OBJECTS) \$(${program}_LDADD) \$(LDADD) \$(LDLIBS) \$(LIBS)\n\n";

            @{$buffers}[BUF_USER] .= "${program_raw}--am-install: \$(AM_DESTDIR)\$(${program_var}dir)/${program_raw}\n";
            @{$buffers}[BUF_USER] .= "${program_raw}--am-uninstall: \$(AM_DESTDIR)\$(${program_var}dir)/${program_raw}--am-uninstall\n";

            @{$buffers}[BUF_USER] .= "am_prog_${program}_name_f_1 = \$(AM_DESTDIR)\$(${program_var}dir)/${program_raw}\n";
            @{$buffers}[BUF_USER] .= "am_prog_${program}_name_f_0 = \n";
            @{$buffers}[BUF_USER] .= "am_prog_${program}_name_f_  = \n";
            @{$buffers}[BUF_USER] .= ".PHONY: \$(am_prog_${program}_name_f_\$(AM_F))\n\n";

            @{$buffers}[BUF_USER] .= "\$(AM_DESTDIR)\$(${program_var}dir)/${program_raw}: ${program_raw} \$(AM_DESTDIR)\$(${program_var}dir)\n";
            @{$buffers}[BUF_USER] .= "\t\$(AM_V_INSTALL) -m 0755 ${program_raw} '\$(AM_DESTDIR)\$(${program_var}dir)'\n";

            @{$buffers}[BUF_USER] .= "\$(AM_DESTDIR)\$(${program_var}dir)/${program_raw}--am-uninstall:\n";
            @{$buffers}[BUF_USER] .= "\t\$(AM_V_UNINSTALL) '\$(\@:--am-uninstall=)'\n";

            cleanup ($program_raw, $program, $context);
        }

        @{$buffers}[BUF_USER] .= "\$(AM_DESTDIR)\$(${program_var}dir):\n";
        @{$buffers}[BUF_USER] .= "\t\$(AM_V_MKDIR_P) \$\@\n\n";
        @{$buffers}[BUF_USER] .= "clean-am: \$(${program_var}_PROGRAMS:=--am-clean)\n";
        @{$buffers}[BUF_USER] .= "install-am: \$(${program_var}_PROGRAMS:=--am-install)\n\n";
        @{$buffers}[BUF_USER] .= "uninstall-am: \$(${program_var}_PROGRAMS:=--am-uninstall)\n\n";
    }

    foreach my $lib_var (keys %{%$context{lib_vars}}) {
        @$buffers[BUF_END] .= "all-am: \$(${lib_var}_LIBRARIES)\n";

        my $libs = %{%$context{lib_vars}}{$lib_var};
        my @libs_list = split (/\s+/, $libs);

        foreach my $lib_raw (@libs_list) {
            my $lib = $lib_raw;
            $lib =~ s/[\.-\/]/_/g;

            @{$buffers}[BUF_USER] .= "${lib_raw}--am-all: ${lib_raw}\n";
            @{$buffers}[BUF_USER] .= "${lib_raw}: \$(${lib}_OBJECTS)\n";
            @{$buffers}[BUF_USER] .= "\t\$(AM_V_AR) \$(AM_ARFLAGS) \$(ARFLAGS) \$(${lib}_ARFLAGS) rcs \$@ \$(${lib}_OBJECTS) \$(${lib}_LIBADD) \$(LIBADD) \$(LIBS)\n\n";

            @{$buffers}[BUF_USER] .= "${lib_raw}--am-install: \$(AM_DESTDIR)\$(${lib_var}dir)/${lib_raw}\n";
            @{$buffers}[BUF_USER] .= "${lib_raw}--am-uninstall: \$(AM_DESTDIR)\$(${lib_var}dir)/${lib_raw}--am-uninstall\n";

            @{$buffers}[BUF_USER] .= "am_lib_${lib}_name_f_1 = \$(AM_DESTDIR)\$(${lib_var}dir)/${lib_raw}\n";
            @{$buffers}[BUF_USER] .= "am_lib_${lib}_name_f_0 = \n";
            @{$buffers}[BUF_USER] .= "am_lib_${lib}_name_f_  = \n";
            @{$buffers}[BUF_USER] .= ".PHONY: \$(am_lib_${lib}_name_f_\$(AM_F))\n\n";

            @{$buffers}[BUF_USER] .= "\$(AM_DESTDIR)\$(${lib_var}dir)/${lib_raw}: ${lib_raw} \$(AM_DESTDIR)\$(${lib_var}dir)\n";
            @{$buffers}[BUF_USER] .= "\t\$(AM_V_INSTALL) -m 0644 ${lib_raw} '\$(AM_DESTDIR)\$(${lib_var}dir)'\n";

            @{$buffers}[BUF_USER] .= "\$(AM_DESTDIR)\$(${lib_var}dir)/${lib_raw}--am-uninstall:\n";
            @{$buffers}[BUF_USER] .= "\t\$(AM_V_UNINSTALL) '\$(\@:--am-uninstall=)'\n";

            cleanup ($lib_raw, $lib, $context);
        }

        @{$buffers}[BUF_USER] .= "\$(AM_DESTDIR)\$(${lib_var}dir):\n";
        @{$buffers}[BUF_USER] .= "\t\$(AM_V_MKDIR_P) \$\@\n\n";
        @{$buffers}[BUF_USER] .= "clean-am: \$(${lib_var}_LIBRARIES:=--am-clean)\n";
        @{$buffers}[BUF_USER] .= "install-am: \$(${lib_var}_LIBRARIES:=--am-install)\n\n";
        @{$buffers}[BUF_USER] .= "uninstall-am: \$(${lib_var}_LIBRARIES:=--am-uninstall)\n\n";
    }

    @$buffers[BUF_END] .= "\n";
}

1;
