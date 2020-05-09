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

    Token[] nextLine(string stringInput = null) {
        if (stringInput is null) {
            if (input == stdin)
                write(">> ");
            line = input.readln();
            if (line is null) {
                return [];
            }
        } else {
            line = stringInput ~ '\n';
        }
        pos = 0;
        Token t = next();
        Token[] list;
        while (t.type != TokenType.EOL) {
            list ~= t;
            t = next();
        }
        list ~= t;
        return list;
    }

    Token next() {
        while (!eol() && isWhite(line[pos]))
            pos++;
        if (eol()) {
            return Token(TokenType.EOL, "");
        }
        const ch = line[pos];
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
    pragma(inline, true) bool eol() pure nothrow const {
        return line.length == 0 || line[pos] == '\n';
    }

    string name() {
        const start = pos;
        while (!eol() && (isAlpha(line[pos]) || isDigit(line[pos])))
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
        if (hadDot && (pos - start) == 1)
            throw new LexerException("Point is not a number");
        return line[start .. pos];
    }
}
