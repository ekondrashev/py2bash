# Purpose of a project.
The project aims to create a simple and convenient tool for converting scripts written in Python, in a sequence of bash commands.

# Features supported(for, sequence, if-else, etc).
The program correctly converts the following language constructs of Python:
* for i in range() (or xrange()) with different number of parameters to be passed in a similar construction shell bash: for (i = BEGIN; i <= END; i ++) or for i in {BEGIN..END};
* implementation using the print output is converted to a similar design echo;
* also processed string literals and numeric values.

# Current approach used(python ast and node visitor).
To analyze and convert Python script commands in the program used class NodeVisitor module ast (Abstract Syntax Trees).
Module 'ast' helps Python applications to process trees of the Python abstract syntax grammar. This module helps to find out programmatically what the current grammar looks like.
In Abstract Syntax Trees (AST) as internal vertices are the operators of the programming language, as well as the leaves - the operands they passed.
Thus, in contrast to the parse tree in AST does not include items that do not affect the semantics of the program, such as braces, semicolons, and so on, because the information about the division of the organization itself carries nodes in the tree.

# Usage:
python main.py [-h] [-o {mem,spd}] [-v] pyscript
pyscript - mandatory command-line argument specifies the file name * .py
Optional arguments:
-h, --help	- displays the help message and exit the program;
-o [mem,spd], --optimized [mem,spd]	- optimizing code for efficient use of memory, or the maximum speed;
-v, --verbose	- enable verbose output.

# Requirements:
Python 2.7.9

# Reference.
[Python ast module usage examples](http://stackoverflow.com/questions/1515357/simple-example-of-how-to-use-ast-nodevisitor)
