'''
Created on Jan 10, 2015

@author: ekondrashev
'''
import unittest
from py2bash import py2bash


class Test(unittest.TestCase):


    def test_for_loop_seq(self):
        actual = py2bash('''for i in range(0, 5):
    print i''')
        expected = '''for i in {0..5}
do
    echo $i
done'''
        self.assertEquals(expected, actual)


if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testName']
    unittest.main()