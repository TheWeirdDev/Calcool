module calcool.expression;

import std.math;
import std.algorithm;

import calcool.exceptions : ParseException;

public:

interface Expression {
    real evaluate() const;
    string toString() @safe const;
}

class FuncExpression : Expression {
private:
    Expression param;
    string name;

    static immutable {
        real function(real) pure @safe nothrow @nogc[string] funcs;
        auto trigonometry = ["sin", "cos", "tan",];
        auto other = ["sqrt", "floor", "ceil", "log", "log2", "log10", "exp"];
    }

    shared static this() {
        static foreach (i; trigonometry ~ other) {
            funcs[i] = mixin("&" ~ i);
        }
        funcs["abs"] = &abs!real;
    }

public:

    this(string n, Expression p) {
        param = p;
        name = n;
        if (cast(EolExpression) param) {
            throw new ParseException("Operand needed");
        }
    }

    override real evaluate() const {
        import std.algorithm : canFind;

        if (name in funcs) {
            if (trigonometry.canFind(name)) {
                auto ret = funcs[name](param.evaluate() * PI / 180);
                if (ret > -1.0e-17 && ret < 1.0e-17)
                    ret = 0;
                return ret;
            }
            return funcs[name](param.evaluate());
        }
        throw new ParseException("Unknown function call");
    }

    override string toString() @safe const {
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

    override real evaluate() const {
        const rhs = right.evaluate();
        static if (op == "/") {
            if (rhs == 0) {
                throw new ParseException("Devide by zero");
            }
        }
        return mixin("left.evaluate()" ~ op ~ "rhs");
    }

    override string toString() @safe const {
        return left.toString() ~ ' ' ~ op[0] ~ ' ' ~ right.toString();
    }
}

class GroupExpression : Expression {
    private Expression inside;

    this(Expression i) {
        inside = i;
    }

    override real evaluate() const {
        return inside.evaluate();
    }

    override string toString() @safe const {
        return "(" ~ inside.toString() ~ ")";
    }
}

class NumberExpression : Expression {
    private real num;

    this(real n) {
        num = n;
    }

    override real evaluate() const {
        return num;
    }

    override string toString() @safe const {
        import std.conv : to;

        return num.to!string;
    }
}

class ConstantExpression : Expression {
    private string constant_name;
    this(string c) {
        import std.uni : toUpper;

        constant_name = c.toUpper();
    }

    override real evaluate() const {
        import std.math.constants;

        immutable CONSTANTS = [
            "E" : E, "PI" : PI, "INF" : real.infinity, "NAN" : real.nan
        ];

        if (auto constant_value = constant_name in CONSTANTS) {
            return *constant_value;
        }
        throw new ParseException("Unknown constant or variable");
    }

    override string toString() @safe const {
        return constant_name;
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

    override real evaluate() const {
        return -right.evaluate();
    }

    override string toString() @safe const {
        return "-" ~ right.toString();
    }
}

class EolExpression : Expression {
    import calcool.exceptions : EolException;

    override real evaluate() const {
        throw new EolException();
    }

    override string toString() @safe const {
        return "";
    }
}
