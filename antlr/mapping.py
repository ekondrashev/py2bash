'''
Created on Jan 10, 2015

@author: ekondrashev
'''

import _ast
import BashastParser
from org.antlr.v4.runtime.tree import TerminalNodeImpl
from org.antlr.v4.runtime import CommonToken
from operator import attrgetter
import ast


def handle_for(e):
    pattern = '''for %s in %s
do
    %s
done'''
    target = handle(e.target)
    iter_ = handle(e.iter)
    body = map(handle, e.body)
    return pattern % (target, iter_, '\n    '.join(body))


def handle_name(e):
    if type(e.ctx) == _ast.Load:
        return '$%s' % e.id
    return e.id


def handle_num(e):
    return e.n


def handle_range(e):
    range_ = tuple(map(handle, e.args))
    return '{%d..%d}' % range_

def handle_func(e):
    handle = {
     'range': handle_range,
     }.get(e.func.id)
    return handle and handle(e)


def handle_call(e):
    r = handle_func(e)
    if r:
        return r
    raise NotImplementedError('handle_call: %s' % ast.dump(e))

def handle_print(e):
#     token = CommonToken(BashastParser.NAME, "echo")
# #     child = TerminalNodeImpl(token)
#     name = BashastParser.NameContext()
#     name.addChild(token)
    r = 'echo %s' % ' '.join(map(handle, e.values))
    return r

MAPPING = {
           _ast.For: handle_for,
           _ast.Name: handle_name,
           _ast.Num: handle_num,
           _ast.Call: handle_call,
           _ast.Print: handle_print
           }

def handle(e):
    cls = e.__class__
    handle = MAPPING.get(cls)
    return handle(e)