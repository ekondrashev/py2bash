'''
Created on Jan 10, 2015

@author: ekondrashev
'''
import unittest
from main import py2bash
from py2bash.base.node import Visitor


class Test(unittest.TestCase):


    def test_single_arg(self):
        actual = py2bash('''print "Wind"''', Visitor())
        expected = '''echo "Wind"'''
        self.assertEquals(expected, actual)

    def test_multiple_args_same_doublequotes(self):
        actual = py2bash('''print "Wind" "Fire"''', Visitor())
        expected = '''echo "WindFire"'''
        self.assertEquals(expected, actual)

    def test_multiple_args_same_singlequotes(self):
        actual = py2bash('''print "Wind" \'Fire\'''', Visitor())
        expected = '''echo "WindFire"'''
        self.assertEquals(expected, actual)
    
    def test_print_variable(self):
        actual = py2bash('''a = 2
print a''', Visitor())
        expected = '''a=2
echo $a'''
        self.assertEquals(expected, actual)
        
if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testName']
    unittest.main()