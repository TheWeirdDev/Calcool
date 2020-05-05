import std.stdio;

import calcool.lexer;
import calcool.token;

void main() {
	auto l = new Lexer();
	l.nextLine().writeln();
}
