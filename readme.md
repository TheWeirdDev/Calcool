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

```d
auto p = new Prser();
string result = p.evaluateFromString("sin(45*2) - 22 * -exp(3)");
```

# License

GPL-3.0+
