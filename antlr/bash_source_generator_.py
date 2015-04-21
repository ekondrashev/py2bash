'''
Created on Jan 7, 2015

@author: ekondrashev
'''
import BashastBaseListener
class Listener(BashastBaseListener):
    def __init__(self, print_fn):
        BashastBaseListener.__init__(self)
        self.print_fn = print_fn

    def enterFirst_line_comment(self, ctx):
        self.print_fn("Enter first line comment")

    def enterFor_expr(self, ctx): 
        self.print_fn("Enter for expr")
    
    def enterWspace(self, ctx):
        self.print_fn("Enter wspace")
        
    def enterBrace_expansion(self, ctx):
        self.print_fn("Enter Brace_expansion")
    
    def enterRange(self, ctx):
        self.print_fn("Enter range")

    def enterVariable_reference(self, ctx):
        self.print_fn("Enter variable_reference")

    def enterName(self, ctx):
        self.print_fn("Enter name: %s" % ctx.getText())

    def enterCommand(self, ctx):
        self.print_fn("Enter command: %s" % ctx.getText())