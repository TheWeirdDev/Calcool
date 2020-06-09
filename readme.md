# Calcool

A terminal based calculator based on pratt's parser and written in D

# How to run?

Install `dub` and `ldc` on your system, then run:

```bash
dub --compiler=ldc
```

# Usage

### Use in command line

```
Usage: calcool [OPTION] [ARGUMENT]
        -h : Print this help message
        -i : Set input file (each expression in a separate line)
        -c : Calculate the given expression
```

### Use as a library

Add calcool to your dependencies

```json
"dependencies": {
    "calcool": "~>1.2.0"
}
```

Set its subconfiguration to `Library`

```json
"configurations": [{
    "name": "your app's name",
    "subConfigurations": {
        "calcool": "Library"
    }
}]
```

Use it in your app

```d
import calcool.parser;

auto p = new Prser();

try {
    // You can call evaluateFromString as many times as you want
    string result = p.evaluateFromString("sin(45*2) - 22 * -exp(3)");
    writeln(result);
} catch (CalcoolException ce) {
    // CalcoolException means your expression was not valid
    stderr.writefln(ce.msg);
} catch (EndException e) {
    // Ignore EndException, it only indicates the end of parsing phase, sorry
} catch (Exception e) {
    // Something bad happened! Do what you have to do.
}

```

# License

GPL-3.0+
