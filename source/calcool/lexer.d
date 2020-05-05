module calcool.lexer;
import std.stdio;
import std.ascii;
import calcool.token;

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

    Token[] nextLine() {
        write(">> ");
        line = input.readln();
        pos = 0;
        Token t = next();
        Token[] list;
        while (t.type != TokenType.EOL) {
            list ~= t;
            t = next();
        }
        return list;
    }

    Token next() {
        while (!eol() && isWhite(line[pos]))
            pos++;
        if (eol()) {
            return Token(TokenType.EOL, "");
        }
        const ch = line[pos];
        if (isDigit(ch)) {
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
    pragma(inline, true) bool eol() pure nothrow {
        return line.length == 0 || pos >= line.length - 1 || line[pos] == '\n';
    }

    string name() {
        const start = pos;
        while (!eol() && isAlpha(line[pos]))
            pos++;
        return line[start .. pos];
    }

    string number() {
        const start = pos;
        bool hadDot = false;
        while (!eol()) {
            if (line[pos] == '.') {
                if (!hadDot)
                    hadDot = true;
                else
                    throw new LexerException("Unknown number passed");
            } else if (!isDigit(line[pos])) {
                break;
            }
            pos++;
        }
        return line[start .. pos];
    }
}

public class LexerException : Exception {
    this(string msg) {
        super(msg);
    }
}
