module calcool.parselets;

import calcool.expression;
import calcool.token;
import calcool.parser;
import calcool.exceptions;

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
    Precedence getPrecedence() immutable;
}

interface PrefixParselet : Parselet {
    Expression parse(Parser, Token) immutable;
}

interface InfixParselet : Parselet {
    Expression parse(Parser, Expression, Token) immutable;
}

public:
class NumberParselet : PrefixParselet {
    override Precedence getPrecedence() immutable {
        return Precedence.NAME_AND_NEGATE;
    }

    override Expression parse(Parser, Token token) immutable {
        if (token.type != TokenType.NUMBER) {
            throw new ParseException("Unknown token passed to number parselet");
        }

        import std.conv : to;

        return new NumberExpression(token.value.to!real);
    }
}

class ConstantParselet : PrefixParselet {
    override Precedence getPrecedence() immutable {
        return Precedence.NAME_AND_NEGATE;
    }

    override Expression parse(Parser, Token token) immutable {
        return new ConstantExpression(token.value);
    }
}

class NegateParselet : PrefixParselet {
    override Precedence getPrecedence() immutable {
        return Precedence.NAME_AND_NEGATE;
    }

    override Expression parse(Parser p, Token token) immutable {
        return new NegateExpression(p.parseExpression(Precedence.NAME_AND_NEGATE));
    }
}

class EolParselet : PrefixParselet {
    override Precedence getPrecedence() immutable {
        return Precedence.START;
    }

    override Expression parse(Parser p, Token token) immutable {
        return new EolExpression();
    }
}

class FuncParselet : PrefixParselet {
    override Precedence getPrecedence() immutable {
        return Precedence.FUNC;
    }

    override Expression parse(Parser p, Token token) immutable {
        p.expect(TokenType.PR_OPEN);
        auto param = p.parseGroupExpression();
        return new FuncExpression(token.value, param);
    }
}

class GroupParselet : PrefixParselet {
    override Precedence getPrecedence() immutable {
        return Precedence.GROUP;
    }

    override Expression parse(Parser p, Token token) immutable {
        return new GroupExpression(p.parseGroupExpression());
    }
}

class MultDivParselet : InfixParselet {
    override Precedence getPrecedence() immutable {
        return Precedence.MULT_AND_DIV;
    }

    override Expression parse(Parser p, Expression left, Token token) immutable {
        auto right = p.parseExpression(Precedence.MULT_AND_DIV);
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
    override Precedence getPrecedence() immutable {
        return Precedence.ADD_AND_MINUS;
    }

    override Expression parse(Parser p, Expression left, Token token) immutable {
        auto right = p.parseExpression(Precedence.ADD_AND_MINUS);
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
    override Precedence getPrecedence() immutable {
        return Precedence.POWER;
    }

    override Expression parse(Parser p, Expression left, Token token) immutable {
        return new OperatorExpression!"^^"(left, p.parseExpression(Precedence.POWER));
    }
}
