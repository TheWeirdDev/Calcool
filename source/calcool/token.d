module calcool.token;

public:
enum TokenType {
    NUMBER,
    IDENTIFIER,
    SET_VAR,
    EQUALS,
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
