module calcool.exceptions;

public:
class ParseException : Exception {
    this(string msg) {
        super(msg);
    }
}

class UnsupportedTokenException : Exception {
    this(char t) {
        import std.format : format;

        super(format("Unsupported token: %c", t));
    }
}

class EolException : Exception {
    this() {
        super("EOL");
    }
}

class EofException : Exception {
    this(string msg) {
        super(msg);
    }
}

class LexerException : Exception {
    this(string msg) {
        super(msg);
    }
}
