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
        pattern = '''for ((%(i)s=%(start)s;%(i)s<=%(end)s;%(step)s))
do
    %(body)s
done'''
        target = self.visit(e.target)
        if not e.iter.func.id in ('range', 'xrange'):
            raise NotImplementedError(e.func.id)
        iter_ = self.visit(e.iter)
        if len(iter_) == 1:
            start, end, step = 0, iter_[0], 1
        elif len(iter_) == 2:
            start, end, step = iter_[0], iter_[1], 1
        elif len(iter_) == 3:
            start, end, step = iter_
        else:
            raise NotImplementedError(iter_)
        body = map(self.visit, e.body)
        
        if step == 1:
            step = '%s++' % target
        else:
            step = '%s+=%s' % (target, step)
        
        return pattern % {
                         'i': target,
                         'start': start,
                         'end': end,
                         'step': step,
                         'body':'\n    '.join(body)
                        }