module calcool.app;
version (CLI_APP) {
	import std.stdio;
	import std.getopt;
	import std.file;

	import calcool.parser;
	import calcool.token;
	import calcool.exceptions;

	enum usage = q{Usage: calcool [OPTION] [ARGUMENT]
	-h : Print this help message
	-i : Set input file (each expression separated by newline)
	-c : Calculate the given expression};

	int main(string[] args) {
		string inputPath = null;
		string inputExpression = null;
		const opts = getopt(args, "i", &inputPath, "c", &inputExpression);
		auto p = new Parser();

		if (opts.helpWanted) {
			writeln(usage);
		} else if (inputPath !is null) {
			if (exists(inputPath) && isFile(inputPath)) {
				p.setInput(File(inputPath));
				run(p);
			} else {
				stderr.writefln("Error: can't open file '%s'", inputPath);
				return 1;
			}
		} else if (inputExpression !is null) {
			return run(p, inputExpression);
		} else {
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
			} catch (EolException e) {
				continue;
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
		} catch (EndException e) {
			return 0;
		} catch (Exception e) {
			return 2;
		}
		return 0;
	}
}
