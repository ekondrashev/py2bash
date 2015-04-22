'''
Created on Jan 6, 2015

@author: ekondrashev
'''
from __future__ import with_statement

import ast, _ast
import argparse
import logging
import py2bash.optimized.speed.node as speed
import py2bash.optimized.memory.node as memory

__author__ = "Eugene Kondrashev"
__copyright__ = "Copyright 2015, Eugene Kondrashev"
__credits__ = ["Eugene Kondrashev"]
__license__ = "MIT"
__version__ = "0.0.1"
__maintainer__ = "Eugene Kondrashev"
__email__ = "eugene.kondrashev@gmail.com"
__status__ = "Prototype"


parser = argparse.ArgumentParser()
parser.add_argument("pyscript")
parser.add_argument("-o", "--optimized", choices=("mem", "spd"), default='mem')
parser.add_argument("-v", "--verbose", help="increase output verbosity",
                    action="store_true")

    

def py2bash(pycode, visitor):
    tree = ast.parse(pycode)
    return visitor.visit(tree)

def main(p, visitor):
    with open(p) as f:
        return py2bash(f.read(), visitor=visitor)

if __name__ == '__main__':
    args = parser.parse_args()
    if args.verbose:
        level = logging.DEBUG
    else:
        level = logging.INFO
    print main(args.pyscript, {'mem': memory.Visitor,
                               'spd': speed.Visitor}.get(args.optimized)())
    
    
