module calcool.expression;

import std.math;
import std.algorithm;

import calcool.exceptions : ParseException;

public:

interface Expression {
    real evaluate();
    string toString();
}

class FuncExpression : Expression {
private:
    Expression param;
    string name;
    static real function(real)[string] funcs;
    static immutable trigonometry = ["sin", "cos", "tan",];
    static immutable other = ["sqrt", "floor", "ceil", "log", "log2", "log10"];

    shared static this() {
        static foreach (i; trigonometry ~ other) {
            funcs[i] = mixin("&" ~ i);
        }
    }

public:

    this(string n, Expression p) {
        param = p;
        name = n;
        if (cast(EolExpression) param) {
            throw new ParseException("Operand needed");
        }
    }

    override real evaluate() {
        import std.algorithm : canFind;

        if (name in funcs) {
            if (trigonometry.canFind(name)) {
                return funcs[name](param.evaluate() * PI / 180);
            }
            return funcs[name](param.evaluate());
        }
        throw new ParseException("Unknown function call");
    }

    override string toString() {
        return name ~ "(" ~ param.toString() ~ ")";
    }
}

class OperatorExpression(string op) : Expression
        if (["+", "-", "/", "*", "^^"].canFind(op)) {

    private Expression left;
    private Expression right;

    this(Expression l, Expression r) {
        left = l;
        right = r;
        if (cast(EolExpression) right) {
            throw new ParseException("Operand needed");
        }
    }

    private enum str = "left.evaluate()" ~ op ~ "right.evaluate()";
    override real evaluate() {
        return mixin(str);
    }

    override string toString() {
        return str;
    }
}

class GroupExpression : Expression {
    private Expression inside;

    this(Expression i) {
        inside = i;
    }

    override real evaluate() {
        return inside.evaluate();
    }

    override string toString() {
        return "(" ~ inside.toString() ~ ")";
    }
}

class NumberExpression : Expression {
    private real num;

    this(real n) {
        num = n;
    }

    override real evaluate() {
        return num;
    }

    override string toString() {
        import std.conv : to;

        return num.to!string;
    }
}

class NegateExpression : Expression {
    private Expression right;

    this(Expression r) {
        right = r;
        if (cast(EolExpression) right) {
            throw new ParseException("Operand needed");
        }
    }

    override real evaluate() {
        return -right.evaluate();
    }

    override string toString() {
        return "-" ~ right.toString();
    }
}

class EolExpression : Expression {
    import calcool.exceptions : EolException;

    override real evaluate() {
        throw new EolException();
    }

    override string toString() {
        return "";
    }
}
