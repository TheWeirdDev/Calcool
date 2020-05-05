module calcool.parselets;

import calcool.expression;
import calcool.token;
import calcool.parser;

enum Precedence : uint {
    START = 0,
    ADD_AND_MINUS = 1,
    MULT_AND_DIV,
    POWER,
    NAME_AND_NEGATE,
    FUNC,
    GROUP
}

interface Parselet {
    Precedence getPrecedence();
}

interface PrefixParselet : Parselet {
    Expression parse(Parser, Token);
}

interface InfixParselet : Parselet {
    Expression parse(Parser, Expression, Token);
}

public:
class ParseException : Exception {
    this(string msg) {
        super(msg);
    }
}

class NumberParselet : PrefixParselet {
    override Precedence getPrecedence() {
        return Precedence.NAME_AND_NEGATE;
    }

    override Expression parse(Parser, Token token) {
        if (token.type != TokenType.NUMBER) {
            throw new ParseException("Unknown token passed to number parselet");
        }

        import std.conv : to;

        return new NumberExpression(token.value.to!real);
    }
}

class NegateParselet : PrefixParselet {
    override Precedence getPrecedence() {
        return Precedence.NAME_AND_NEGATE;
    }

    override Expression parse(Parser p, Token token) {
        return new NegateExpression(p.parseExpression());
    }
}

class FuncParselet : PrefixParselet {
    override Precedence getPrecedence() {
        return Precedence.FUNC;
    }

    override Expression parse(Parser p, Token token) {
        p.expect(TokenType.PR_OPEN);
        auto param = p.parseGroupExpression();
        switch (token.value) {
        case "sin":
            return new FuncExpression!"sin"(param);
        case "cos":
            return new FuncExpression!"cos"(param);
        case "tan":
            return new FuncExpression!"tan"(param);
        default:
            throw new ParseException("Unknown token for Func parselet");
        }
    }
}

class GroupParselet : PrefixParselet {
    override Precedence getPrecedence() {
        return Precedence.GROUP;
    }

    override Expression parse(Parser p, Token token) {
        return new GroupExpression(p.parseGroupExpression());
    }
}

class MultDivParselet : InfixParselet {
    override Precedence getPrecedence() {
        return Precedence.MULT_AND_DIV;
    }

    override Expression parse(Parser p, Expression left, Token token) {
        auto right = p.parseExpression();
        switch (token.type) {
        case TokenType.OP_MULT:
            return new OperatorExpression!"*"(left, right);
        case TokenType.OP_DIV:
            return new OperatorExpression!"/"(left, right);
        default:
            throw new ParseException("Unknown token for MultDiv parselet");
        }
    }
}

class AddMinusParselet : InfixParselet {
    override Precedence getPrecedence() {
        return Precedence.ADD_AND_MINUS;
    }

    override Expression parse(Parser p, Expression left, Token token) {
        auto right = p.parseExpression();
        switch (token.type) {
        case TokenType.OP_ADD:
            return new OperatorExpression!"+"(left, right);
        case TokenType.OP_MINUS:
            return new OperatorExpression!"-"(left, right);
        default:
            throw new ParseException("Unknown token for AddMinus parselet");
        }
    }
}

class PowerParselet : InfixParselet {
    override Precedence getPrecedence() {
        return Precedence.POWER;
    }

    override Expression parse(Parser p, Expression left, Token token) {
        return new OperatorExpression!"^^"(left, p.parseExpression());
    }
}
