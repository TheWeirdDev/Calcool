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
    real[string] variables;
    Lexer lexer;
    Token[] input;
    static const syntaxError = new ParseException("Syntax error");

    static immutable {
        PrefixParselet[TokenType] prefixParselets;
        InfixParselet[TokenType] infixParselets;
    }

    shared static this() {
        prefixParselets[TokenType.NUMBER] = new NumberParselet();
        prefixParselets[TokenType.IDENTIFIER] = new IdentifierParselet();
        prefixParselets[TokenType.OP_MINUS] = new NegateParselet();
        prefixParselets[TokenType.FUNC] = new FuncParselet();
        prefixParselets[TokenType.PR_OPEN] = new GroupParselet();
        prefixParselets[TokenType.EOL] = new EolParselet();

        infixParselets[TokenType.OP_ADD] = infixParselets[TokenType.OP_MINUS] = new AddMinusParselet();
        infixParselets[TokenType.OP_MULT] = infixParselets[TokenType.OP_DIV] = new MultDivParselet();
        infixParselets[TokenType.OP_POW] = new PowerParselet();
    }

public:
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

    const auto ref getVariables() {
        return variables;
    }

    void setVariable(string name, real value) {
        import std.algorithm : canFind;

        if (FuncExpression.funcNames().canFind(name)) {
            error("Cannot use reserved function name '%s' as a variable", name);
        }
        variables[name] = value;
    }

    private Token consume() {
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
        while (start && token.type == TokenType.EOL) {
            token = consume();
        }

        if (start && token.type == TokenType.SET_VAR) {
            const variable = expect(TokenType.IDENTIFIER);
            expect(TokenType.EQUALS);
            if (input.front().type == TokenType.EOL) {
                error();
            }
            auto expr = parseExpression(Precedence.START, true);
            setVariable(variable.value, expr.evaluate());
            return expr;
        }

        if (auto parselet = token.type in prefixParselets) {
            auto left = parselet.parse(this, token);

            while (precedence < getPrecedence()) {
                token = consume();
                immutable infix = infixParselets[token.type];
                left = infix.parse(this, left, token);
            }

            if (start && input.length > 0 && consume().type != TokenType.EOL) {
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

    private noreturn error(const ParseException exception = syntaxError) {
        input.length = 0;
        throw exception;
    }

    private noreturn error(Args...)(const string msg, Args args) {
        import std.format : format;

        return error(new ParseException(format(msg, args)));
    }

    auto expect(const TokenType t) {
        if ((input.length > 0 && input.front().type != t) || input.length == 0) {
            error("Expected token of type %s", t);
        }
        const res = input.front();
        input.popFront();
        return res;
    }

    string evaluateFromString(in string exp) {
        import std.conv : to;

        input = lexer.nextLine(exp);
        return parseExpression(Precedence.START, true).evaluate().to!string;
    }

}
