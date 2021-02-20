module calcool.app;

version (CLI_APP) {
    import std.stdio;
    import std.getopt;
    import std.file;
    import std.format;

    import calcool.parser;
    import calcool.token;
    import calcool.exceptions;

    enum usage = q{Usage: calcool [OPTION] [ARGUMENT]
	-h : Print this help message
	-i : Set input file (each expression separated by newline)
	-c : Calculate the given expression};

    enum quitIfTooManyArgs(int maxArgs) = format!q{
                if (argnum > %d) {
                    stderr.writeln(
                            "Too many arguments: use -c for an expression or -i for an input file");
                    return 1;
                }
    }(maxArgs);

    int main(string[] args) {
        string inputPath = null;
        string inputExpression = null;
        const argnum = args.length;

        GetoptResult opts;
        try {
            opts = getopt(args, "i", &inputPath, "c", &inputExpression);
        } catch (Exception e) {
            stderr.writefln("Error: %s\n", e.msg);
            return 1;
        }

        auto p = new Parser();
        if (opts.helpWanted) {
            writeln(usage);
        } else if (inputPath !is null) {
            mixin(quitIfTooManyArgs!3);
            if (exists(inputPath) && isFile(inputPath)) {
                p.setInput(File(inputPath));
                run(p);
            } else {
                stderr.writefln("Error: can't open file '%s'\n", inputPath);
                return 1;
            }
        } else if (inputExpression !is null) {
            mixin(quitIfTooManyArgs!3);
            return run(p, inputExpression);
        } else {
            mixin(quitIfTooManyArgs!1);
            run(p);
        }
        return 0;
    }

    void run(ref Parser p) {
        import std.stdio : writeln, stderr;

        while (true) {
            try {
                p.parseExpression().evaluate().writeln();
            } catch (CalcoolException ce) {
                stderr.writeln(ce.msg);
            } catch (EofException e) {
                break;
            } catch (Exception e) {
                stderr.writefln("Error: %s", e.msg);
                break;
            }
        }
    }

    int run(ref Parser p, string input) {
        import std.stdio : writeln, stderr;

        try {
            p.evaluateFromString(input).writeln();
        } catch (CalcoolException ce) {
            stderr.writefln(ce.msg);
            return 1;
        } catch (Exception e) {
            return 2;
        }
        return 0;
    }
}
