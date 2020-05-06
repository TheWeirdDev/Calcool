module calcool.parser;

import std.stdio;
import std.array : front, popFront;

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
        prefixParselets[TokenType.PR_OPEN] = new GroupParselet();
        prefixParselets[TokenType.EOL] = new EolParselet();

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
        if (input.length == 0) {
            input = lexer.nextLine();
            if (input.length == 0) {
                throw new Exception("END OF INPUT");
            }
        }
        const f = input.front();
        input.popFront();
        return f;
    }

    Expression parseExpression() {
        return parseExpression(Precedence.START);
    }

    Expression parseGroupExpression() {
        auto inside = parseExpression(Precedence.START);
        expect(TokenType.PR_CLOSE);
        return inside;
    }

    Expression parseExpression(Precedence precedence) {
        auto token = consume();
        if (auto parselet = token.type in prefixParselets) {
            auto left = parselet.parse(this, token);

            while (precedence < getPrecedence()) {
                token = consume();
                InfixParselet infix = infixParselets[token.type];
                left = infix.parse(this, left, token);
            }
            return left;

        } else {
            input.length = 0;
            throw new ParseException("Syntax error");
        }
    }

    private Precedence getPrecedence() {
        if (input.length > 0) {
            const t = input.front().type;
            if (t == TokenType.PR_CLOSE) {
                return Precedence.START;
            }

            if (auto parselet = t in infixParselets) {
                return parselet.getPrecedence();
            } else if (t == TokenType.EOL) {
                return Precedence.START;
            } else {
                input.length = 0;
                throw new ParseException("Invalid syntax");
            }
        }

        return Precedence.START;
    }

    void expect(TokenType t) {
        if ((input.length > 0 && input.front().type != t) || input.length == 0) {
            import std.format : format;

            input.length = 0;
            throw new ParseException(format("Expected token of type %s", t));
        }
        input.popFront();
    }

    void run() {
        while (true) {
            import std.stdio : writeln, stderr;

            try {
                parseExpression().evaluate().writeln();

            } catch (ParseException p) {
                stderr.writefln("Parser error: %s", p.msg);
            } catch (LexerException l) {
                stderr.writefln("Lexer error: %s", l.msg);
            } catch (UnsupportedTokenException u) {
                stderr.writefln(u.msg);
            } catch (EolException e) {
                continue;
            } catch (Exception e) {
                break;
            }
        }
    }
}
