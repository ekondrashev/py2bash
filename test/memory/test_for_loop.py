'''
Created on Apr 22, 2015

@author: ekondrashev
'''
import unittest
from main import py2bash
from py2bash.optimized.memory.node import Visitor


class Test(unittest.TestCase):


    def test_for_loop_seq_both_boundaries(self):
        actual = py2bash('''for i in range(0, 5):
    print i''', Visitor())
        expected = '''for ((i=0;i<=4;i++))
do
    echo $i
done'''
        self.assertEquals(expected, actual)
    
    def test_for_loop_seq_end_only(self):
        actual = py2bash('''for i in range(5):
    print i''', Visitor())
        expected = '''for ((i=0;i<=4;i++))
do
    echo $i
done'''
        self.assertEquals(expected, actual)
    
    def test_for_loop_seq_var_as_end(self):
        actual = py2bash('''end=5
for i in range(end):
    print i''', Visitor())
        expected = '''end=5
for ((i=0;i<=$(($end-1));i++))
do
    echo $i
done'''
        self.assertEquals(expected, actual)

    def test_for_loop_with_step(self):
        actual = py2bash('''end=5
for i in range(0, end, 2):
    print i''', Visitor())
        expected = '''end=5
for ((i=0;i<=$(($end-1));i+=2))
do
    echo $i
done'''
        self.assertEquals(expected, actual)

    @unittest.skip("Second argument of cycle is incorrectly converted.")
    def test_descending(self):
        actual = py2bash('''end=5
for i in range(end, 0, -2):
    print i''', Visitor())
        expected = '''end=5
for ((i=$end;i>-1;i+=-2))
do
    echo $i
done'''
        self.assertEquals(expected, actual)

if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testName']
    unittest.main()