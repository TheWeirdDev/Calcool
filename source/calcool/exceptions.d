module calcool.exceptions;

public:
class CalcoolException : Exception {
    this(string prefix, string msg) {
        import std.format : format;

        super(format(prefix, msg));
    }
}

class ParseException : CalcoolException {
    this(string msg) {
        super("Parser error: %s", msg);
    }
}

class LexerException : CalcoolException {
    this(string msg) {
        super("Lexer error: %s", msg);
    }
}

class UnsupportedTokenException : CalcoolException {
    this(char t) {
        import std.conv : to;

        super("Unsupported token: %s", t.to!string);
    }
}

class EndException : Exception {
    this() {
        super("END");
    }
}

class EolException : EndException {
    this() {
        super();
    }
}

class EofException : EndException {
    this() {
        super();
    }
}
