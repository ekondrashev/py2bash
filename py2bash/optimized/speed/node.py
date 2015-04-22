'''
Created on Apr 22, 2015

'''
import py2bash.base.node as base

__author__ = "Eugene Kondrashev"
__copyright__ = "Copyright 2015, Eugene Kondrashev"
__credits__ = ["Eugene Kondrashev"]
__license__ = "MIT"
__version__ = "0.0.1"
__maintainer__ = "Eugene Kondrashev"
__email__ = "eugene.kondrashev@gmail.com"
__status__ = "Prototype"


class Visitor(base.Visitor):
    
    def visit_For(self, e):
        pattern = '''for %s in %s
do
    %s
done'''
        target = self.visit(e.target)
        iter_ = self.visit(e.iter)
        body = map(self.visit, e.body)
        return pattern % (target, iter_, '\n    '.join(body))
    
    
    def handle_range(self, e):
        range_ = tuple(map(self.visit, e.args))
        if len(range_) == 1:
            start, end = 0, range_[0]
        else:
            start, end = range_
        start, end = str(start), str(end)
        if start.isdigit() and end.isdigit():
            p = '{%s..%s}'
            end = str(long(end) - 1)
        else:
            p = '$(eval echo {%s..$((%s-1))})'
        return p % (start, end)