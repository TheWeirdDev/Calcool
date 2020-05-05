module calcool.parser;

import std.stdio;

import calcool.lexer;
import calcool.token;

public class Parser {
private:
    Lexer lexer;

public:
    this() {
        lexer = new Lexer();
    }

    this(File f) {
        lexer = new Lexer(f);
    }

}
