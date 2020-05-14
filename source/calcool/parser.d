module calcool.parser;

import std.stdio;
import std.array : front, popFront;

import calcool.lexer;
import calcool.token;
import calcool.expression;
import calcool.parselets;
import calcool.exceptions;

public class Parser {
private:
    Lexer lexer;

    static {
        PrefixParselet[TokenType] prefixParselets;
        InfixParselet[TokenType] infixParselets;

        void registerParselets() {
            prefixParselets[TokenType.NUMBER] = new NumberParselet();
            prefixParselets[TokenType.OP_MINUS] = new NegateParselet();
            prefixParselets[TokenType.FUNC] = new FuncParselet();
            prefixParselets[TokenType.PR_OPEN] = new GroupParselet();
            prefixParselets[TokenType.EOL] = new EolParselet();

            infixParselets[TokenType.OP_ADD] = infixParselets[TokenType.OP_MINUS] = new AddMinusParselet();
            infixParselets[TokenType.OP_MULT] = infixParselets[TokenType.OP_DIV] = new MultDivParselet();
            infixParselets[TokenType.OP_POW] = new PowerParselet();

        }
    }

    shared static this() {
        registerParselets();
    }

public:
    Token[] input;
    private static const syntaxError = new ParseException("Syntax error");

    this() {
        lexer = new Lexer();
    }

    this(File f) {
        lexer = new Lexer(f);
    }

    void setInput(File f) {
        lexer = new Lexer(f);
        input.length = 0;
    }

    Token consume() {
        if (input.length == 0) {
            input = lexer.nextLine();
            if (input.length == 0) {
                throw new EofException();
            }
        }
        const f = input.front();
        input.popFront();
        return f;
    }

    Expression parseGroupExpression() {
        auto inside = parseExpression(Precedence.START);
        expect(TokenType.PR_CLOSE);
        return inside;
    }

    Expression parseExpression() {
        return parseExpression(Precedence.START, true);
    }

    Expression parseExpression(const Precedence precedence = Precedence.START, bool start = false) {
        auto token = consume();
        if (auto parselet = token.type in prefixParselets) {
            auto left = parselet.parse(this, token);

            while (precedence < getPrecedence()) {
                token = consume();
                InfixParselet infix = infixParselets[token.type];
                left = infix.parse(this, left, token);
            }

            if (start && input.length > 0 && input.front().type != TokenType.EOL) {
                error();
            }
            return left;

        } else {
            error();
        }
        assert(false);
    }

    private Precedence getPrecedence() {
        if (input.length > 0) {
            const t = input.front().type;
            if (t == TokenType.PR_CLOSE || t == TokenType.EOL) {
                return Precedence.START;
            }

            if (auto parselet = t in infixParselets) {
                return parselet.getPrecedence();
            } else {
                error();
            }
        }

        return Precedence.START;
    }

    private void error() {
        input.length = 0;
        throw syntaxError;
    }

    void expect(const TokenType t) {
        if ((input.length > 0 && input.front().type != t) || input.length == 0) {
            import std.format : format;

            input.length = 0;
            throw new ParseException(format("Expected token of type %s", t));
        }
        input.popFront();
    }

    string evaluateFromString(in string exp) {
        import std.conv : to;

        input = lexer.nextLine(exp);
        return parseExpression(Precedence.START, true).evaluate().to!string;
    }

}
