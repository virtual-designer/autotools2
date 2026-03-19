function basename(path) {
    n = split(path, components, /\/+/);
    return components[n];
}

BEGIN {
    n = split(SUBST_BUF, lines, /\n/);

    for (i = 1; i <= n; i++) {
        eqind = index(lines[i], "=");
        name = substr(lines[i], 1, eqind - 1);
        value = substr(lines[i], eqind + 1);
        vars[name] = value;
    }

    OUTFILE_BASE = basename(OUTFILE);
    is_makefile = tolower(OUTFILE_BASE) == "makefile" ||
                  tolower(OUTFILE_BASE) ~ /^(makefile|gnumakefile)\./ ||
                  tolower(OUTFILE_BASE) == "gnumakefile" ||
                  tolower(OUTFILE_BASE) ~ /\.(am|mk|makefile)$/;

    cond_count = 0;
    begin = 1;
}

/^#\+\$if / {
    cond = substr($0, 6);
    gsub(/^\s+/, "", cond);
    flip = substr (cond, 1, 1) == "!";
    gsub(/^(!)?\s+/, "", cond);

    cond = "__COND_" cond;
    pair[1] = cond;

    if (!(cond in vars) || vars[cond] == "" || vars[cond] == "0") {
        pair[2] = 0;
    }
    else {
        pair[2] = 1;
    }

    if (flip) {
        pair[2] = !pair[2];
    }

    cond_stack[++cond_count] = pair[2] "" pair[1];
    next;
}

/^#\+\$endif/ {
    if (cond_count > 0) {
        cond_count--;
    }

    next;
}

cond_count == 0 || substr(cond_stack[cond_count], 1, 1) == "1" {
    if ($0 ~ /^#/) {
        print;
        next;
    }
    else if (begin || !is_makefile) {
        begin = 0;
        print "";

        if (is_makefile) {
            for (name in vars) {
                print name " = " vars[name];
            }
        }
    }


    for (name in vars) {
        sub("@" name "@", vars[name], $0);

        if (is_makefile) {
            sub("$(" name ")", vars[name], $0);
        }
    }

    print;
}
