module calcool.parser;

import std.stdio;

import calcool.lexer;
import calcool.token;
import calcool.expression;
import calcool.parselets;

public class Parser {
private:
    Lexer lexer;

    static PrefixParselet[TokenType] prefixParselets;
    static InfixParselet[TokenType] infixParselets;

    static void registerParselets() {
        prefixParselets[TokenType.NUMBER] = new NumberParselet();
        prefixParselets[TokenType.OP_MINUS] = new NegateParselet();
        prefixParselets[TokenType.FUNC] = new FuncParselet();

        infixParselets[TokenType.OP_ADD] = infixParselets[TokenType.OP_MINUS] = new AddMinusParselet();
        infixParselets[TokenType.OP_MULT] = infixParselets[TokenType.OP_DIV] = new MultDivParselet();
        infixParselets[TokenType.OP_POW] = new PowerParselet();

    }

    shared static this() {
        registerParselets();
    }

public:
    Token[] input;

    this() {
        lexer = new Lexer();
    }

    this(File f) {
        lexer = new Lexer(f);
    }

    Token consume() {
        import std.array : front, popFront;

        if (input.length == 0) {
            input = lexer.nextLine();
        }
        const f = input.front();
        input.popFront();
        return f;
    }

    Expression parseExpression() {
        return new NumberParselet().parse(this, consume());
    }

}
