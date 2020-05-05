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
        if (isDigit(ch))
            return Token(TokenType.NUMBER, until!isDigit());
        else if (isAlpha(ch))
            return Token(TokenType.FUNC, until!isAlpha());

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
        return line[pos] == '\n' || pos >= line.length - 1;
    }

    string until(alias Pred)() {
        const start = pos;
        while (!eol() && Pred(line[pos]))
            pos++;
        return line[start .. pos];
    }

}
