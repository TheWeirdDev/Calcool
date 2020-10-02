module calcool.lexer;
import std.stdio;
import std.ascii;
import calcool.token;
import calcool.exceptions;

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
        while (!eol() && isWhite(peek()))
            pos++;
        if (eol()) {
            return Token(TokenType.EOL);
        }
        const ch = peek();
        if (isDigit(ch) || ch == '.') {
            return Token(TokenType.NUMBER, number());
        } else if (isAlpha(ch))
            return Token(TokenType.FUNC, name());
        pos++;
        switch (ch) {
            import std.conv : to;

        case '(':
            return Token(TokenType.PR_OPEN, ch.to!string);
        case ')':
            return Token(TokenType.PR_CLOSE, ch.to!string);
        case '+':
            return Token(TokenType.OP_ADD, ch.to!string);
        case '-':
            return Token(TokenType.OP_MINUS, ch.to!string);
        case '*':
            return Token(TokenType.OP_MULT, ch.to!string);
        case '/':
            return Token(TokenType.OP_DIV, ch.to!string);
        case '^':
            return Token(TokenType.OP_POW, ch.to!string);
        default:
            throw new UnsupportedTokenException(ch);
        }
    }

private:
    pragma(inline, true) {
        auto eol() pure nothrow const {
            return line.length == 0 || pos >= line.length;
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
    read_digits:
        while (!eol() && isDigit(peek())) {
            pos++;
        }
        if (!eol() && peek() == '.') {
            if (!isFloat) {
                isFloat = true;
                pos++;
                goto read_digits;
            } else {
                throw new LexerException("Unknown number passed");
            }
        }

        if (isFloat && (pos - start) == 1)
            throw new LexerException("Point is not a number");
        return line[start .. pos];
    }
}
