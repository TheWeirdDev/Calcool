module calcool.token;

public:
enum TokenType {
    NUMBER,
    OP_ADD,
    OP_MINUS,
    OP_MULT,
    OP_DIV,
    OP_POW,
    PR_OPEN,
    PR_CLOSE,
    FUNC,
    EOL
}

struct Token {
    TokenType type;
    string value;
}

class UnsupportedTokenException : Exception {
    this(char t) {
        import std.format : format;

        super(format("Unsupported token: %c", t));
    }
}
