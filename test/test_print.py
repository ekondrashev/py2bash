'''
Created on Jan 10, 2015

@author: ekondrashev
'''
import unittest
import main.py2bash


class Test(unittest.TestCase):


    def test_single_arg(self):
        actual = main('''print "Wind"''')
        expected = '''echo "Wind"'''
        self.assertEquals(expected, actual)

    def test_multiple_args_same_doublequotes(self):
        actual = main('''print "Wind" "Fire"''')
        expected = '''echo "WindFire"'''
        self.assertEquals(expected, actual)

    def test_multiple_args_same_singlequotes(self):
        actual = main('''print "Wind" \'Fire\'''')
        expected = '''echo "WindFire"'''
        self.assertEquals(expected, actual)
    
    def test_print_variable(self):
        actual = main('''a = 2
print a''')
        expected = '''a=2
echo $a'''
        self.assertEquals(expected, actual)
        
if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testName']
    unittest.main()