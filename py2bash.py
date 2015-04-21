'''
Created on Jan 6, 2015

@author: ekondrashev
'''
from __future__ import with_statement

import ast
import _ast

class Visitor(ast.NodeVisitor):
#     
#     def __init__(self, print_fn):
#         self.print_fn = print_fn

#     def visit_FunctionDef(self, node):
#         print(node.name)
#         self.generic_visit(node)
    def visit_Module(self, e):
        return '\n'.join(map(self.visit, e.body))
    
    def visit_For(self, e):
        pattern = '''for %s in %s
do
    %s
done'''
        target = self.visit(e.target)
        iter_ = self.visit(e.iter)
        body = map(self.visit, e.body)
        return pattern % (target, iter_, '\n    '.join(body))

    def visit_Name(self, e):
        if type(e.ctx) == _ast.Load:
            return '$%s' % e.id
        return e.id

    def visit_Num(self, e):
        return e.n

    def handle_range(self, e):
        range_ = tuple(map(self.visit, e.args))
        if len(range_) == 1:
            start, end = 0, range_[0]
        else:
            start, end = range_
        return '{%d..%d}' % (start, end - 1)

    def handle_func(self, e):
        handle = {
         'range': self.handle_range,
         'xrange': self.handle_range,
         }.get(e.func.id)
        return handle and handle(e)
    
    
    def visit_Call(self, e):
        r = self.handle_func(e)
        if r:
            return r
        raise NotImplementedError('visit_Call: %s' % ast.dump(e))
    
    def visit_Print(self, e):
        r = 'echo %s' % ' '.join(map(self.visit, e.values))
        return r
    

def py2bash(pycode):
    tree = ast.parse(pycode)
    return Visitor().visit(tree)

def main(p):
    with open(p) as f:
        print py2bash(f.read())

if __name__ == '__main__':
    
#     main('test.sh')
    main('examples/for_loop.py')
    
    