BEGIN {
    n = split(SUBST_BUF, lines, /\n/);

    for (i = 1; i <= n; i++) {
        eqind = index(lines[i], "=");
        name = substr(lines[i], 1, eqind - 1);
        value = substr(lines[i], eqind + 1);
        vars[name] = value;
    }

    is_makefile = tolower(OUTFILE) == "makefile" ||
                  tolower(OUTFILE) ~ /^(makefile|gnumakefile)\./ ||
                  tolower(OUTFILE) == "gnumakefile" ||
                  tolower(OUTFILE) ~ /\.(am|mk|makefile)$/;

    if (is_makefile) {
        for (name in vars) {
            print name " = " vars[name];
        }
    }

    cond_count = 0;
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
    for (name in vars) {
        sub("@" name "@", vars[name], $0);

        if (is_makefile) {
            sub("$(" name ")", vars[name], $0);
        }
    }

    print;
}
