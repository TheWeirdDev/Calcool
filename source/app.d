import std.stdio;

import calcool.parser;
import calcool.token;

void main() {
	auto p = new Parser();
	p.parseExpression().evaluate().writeln();
}
