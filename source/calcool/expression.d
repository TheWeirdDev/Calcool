module calcool.expression;

import std.math;
import std.algorithm;

public:

interface Expression {
    real evaluate();
    string toString();
}

class FuncExpression(string FuncName) : Expression
        if (["sin", "cos", "tan"].canFind(FuncName)) {
    Expression param;

    this(Expression p) {
        param = p;
    }

    override real evaluate() {
        return mixin(FuncName ~ "(param.evaluate()*PI/180)");
    }

    override string toString() {
        return FuncName ~ "(" ~ param.toString() ~ ")";
    }
}

class OperatorExpression(string op) : Expression
        if (["+", "-", "/", "*", "^^"].canFind(op)) {

    private Expression left;
    private Expression right;

    this(Expression l, Expression r) {
        left = l;
        right = r;
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

        return "(" ~ num.to!string ~ ")";
    }
}

class NegateExpression : Expression {
    private Expression right;

    this(Expression r) {
        right = r;
    }

    override real evaluate() {
        return -right.evaluate();
    }

    override string toString() {
        return "-" ~ right.toString();
    }
}
