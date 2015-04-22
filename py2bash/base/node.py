'''
Created on Apr 22, 2015

@author: ekondrashev
'''

import ast, _ast

__author__ = "Eugene Kondrashev"
__copyright__ = "Copyright 2015, Eugene Kondrashev"
__credits__ = ["Eugene Kondrashev"]
__license__ = "MIT"
__version__ = "0.0.1"
__maintainer__ = "Eugene Kondrashev"
__email__ = "eugene.kondrashev@gmail.com"
__status__ = "Prototype"


class Visitor(ast.NodeVisitor):
#     
#     def __init__(self, print_fn):
#         self.print_fn = print_fn

#     def visit_FunctionDef(self, node):
#         print(node.name)
#         self.generic_visit(node)
    def visit_Module(self, e):
        seq = map(self.visit, e.body)
        return '\n'.join(seq)
    
    def visit_Assign(self, e):
        seq = e.targets + [e.value.n, ]
        seq = map(self.visit, seq)
        return '%s=%s' % tuple(seq)
# for ((i=1;i<=$END-1;i++)); do     echo $i; done
    def visit_For(self, e):
        raise NotImplementedError('visit_For') 
    
#     def visit_For(self, e):
#         pattern = '''for %s in %s
# do
#     %s
# done'''
#         target = self.visit(e.target)
#         iter_ = self.visit(e.iter)
#         body = map(self.visit, e.body)
#         return pattern % (target, iter_, '\n    '.join(body))

    def visit_Name(self, e):
        if type(e.ctx) == _ast.Load:
            return '$%s' % e.id
        return e.id

    def visit_int(self, e):
        return str(e)
    
    def visit_Num(self, e):
        return e.n

    def isnumber(self, num):
        try:
            long(num)
            return True
        except ValueError:
            return False

    def handle_range(self, e):
        range_ = tuple(map(self.visit, e.args))
        if len(range_) == 1:
            start, end, step = 0, range_[0], 1
        elif len(range_) == 2:
            start, end, step = range_[0], range_[1], 1
        elif len(range_) == 3:
            start, end, step = range_
        
        if self.isnumber(end):
            end = str(long(end) - 1)
        else:
            end = '$((%s-1))' % end
        return start, end, step

    def handle_func(self, e):
        handle = {
         'range': self.handle_range,
         'xrange': self.handle_range,
         }.get(e.func.id)
        if handle:
            return handle(e)
        raise NotImplementedError(e.func.id)
    
    
    def visit_Call(self, e):
        r = self.handle_func(e)
        if r:
            return r
        raise NotImplementedError('visit_Call: %s' % ast.dump(e))
    
    def visit_Print(self, e):
        seq = map(self.visit, e.values)
        r = 'echo %s' % ' '.join(seq)
        return r
    
    def visit_Str(self, e):
        return '"%s"' % e.s