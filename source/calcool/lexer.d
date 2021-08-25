module calcool.lexer;
import std.stdio;
import std.ascii;
import calcool.token;
import calcool.exceptions;
import std.conv : to;

public class Lexer {
private:
    File input;

    uint pos = 0;
    string line;
public:
    this(File f) {
        input = f;
    }

    this() {
        this(stdin);
    }

    Token[] nextLine(in string stringInput = null) {
        if (stringInput is null) {
            if (input is stdin) {
                version (Posix) {
                    import core.sys.posix.unistd : isatty;

                    if (isatty(stdin.fileno))
                        write(">> ");
                } else {
                    write(">> ");
                }
            }

            line = input.readln();
            if (line is null) {
                return [];
            }
        } else {
            line = stringInput; // ~ '\n';
        }
        pos = 0;
        Token[] list;
        for (auto t = next(); t.type != TokenType.EOL; t = next()) {
            list ~= t;
        }
        list ~= Token(TokenType.EOL);
        return list;
    }

    Token next() {
        skipWhiteSpace();
        if (eol()) {
            return Token(TokenType.EOL);
        }
        const ch = peek();
        if (isDigit(ch) || ch == '.') {
            return Token(TokenType.NUMBER, number());
        } else if (isAlpha(ch)) {
            const identifier = name();
            if (identifier == "set") {
                return Token(TokenType.SET_VAR, identifier);
            }
            skipWhiteSpace();
            if (!eol() && peek() == '(') {
                return Token(TokenType.FUNC, identifier);
            }
            return Token(TokenType.IDENTIFIER, identifier);
        }
        pos++;

        const value = ch.to!string;
        switch (ch) {
        case '(':
            return Token(TokenType.PR_OPEN, value);
        case ')':
            return Token(TokenType.PR_CLOSE, value);
        case '+':
            return Token(TokenType.OP_ADD, value);
        case '-':
            return Token(TokenType.OP_MINUS, value);
        case '*':
            return Token(TokenType.OP_MULT, value);
        case '/':
            return Token(TokenType.OP_DIV, value);
        case '^':
            return Token(TokenType.OP_POW, value);
        case '=':
            return Token(TokenType.EQUALS, value);
        default:
            throw new UnsupportedTokenException(ch);
        }
    }

private:
    pragma(inline, true) {
        auto eol() pure nothrow const {
            return line.length == 0 || pos >= line.length;
        }

        auto skipWhiteSpace() {
            while (!eol() && isWhite(peek()))
                pos++;
        }

        auto ref peek() {
            return line[pos];
        }
    }

    auto name() {
        const start = pos;
        while (!eol() && (isAlpha(peek()) || isDigit(peek())))
            pos++;
        return line[start .. pos];
    }

    string number() {
        const start = pos;
        bool isFloat = false;
        bool shouldContinue = true;

        while (shouldContinue) {
            while (!eol() && isDigit(peek())) {
                pos++;
            }
            if (!eol() && peek() == '.') {
                if (!isFloat) {
                    isFloat = true;
                    pos++;
                } else {
                    throw new LexerException("Invalid number");
                }
            } else {
                shouldContinue = false;
            }
        }

        if (!eol() && peek() == 'e') {
            pos++;
            if (!eol() && (peek() == '+' || peek() == '-')) {
                pos++;
            }
            if (!eol() && !isDigit(peek())) {
                throw new LexerException("Invalid number");
            }
            while (!eol() && isDigit(peek())) {
                pos++;
            }
        }

        if (isFloat && (pos - start) == 1)
            throw new LexerException("Point is not a number");
        return line[start .. pos];
    }
}
