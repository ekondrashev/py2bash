import unittest
from main import py2bash
from py2bash.base.node import Visitor
from subprocess import Popen, PIPE, STDOUT


class Test(unittest.TestCase):


    def test_bash_print_single_arg(self):
        expected = 'Wind'
        cmd = py2bash('''print "{}"'''.format(expected), Visitor())
        p = Popen(['bash', '-c', cmd], stderr=STDOUT, stdout=PIPE)
        actual = ''.join(p.stdout.read().rsplit('\r\n'))
        self.assertEquals(expected, actual)

    def test_bash_print_multiple_args_same_doublequotes(self):
        str1, str2 = "Wind", "Fire"
        expected = str1 + str2
        cmd = py2bash('''print "{}" "{}"'''.format(str1, str2), Visitor())
        p = Popen(['bash', '-c', cmd], stderr=STDOUT, stdout=PIPE)
        actual = ''.join(p.stdout.read().rsplit('\r\n'))
        self.assertEquals(expected, actual)

    def test_bash_print_multiple_args_same_singlequotes(self):
        str1, str2 = "Wind", "Fire"
        expected = str1 + str2
        cmd = py2bash('''print "{}" \'{}\''''.format(str1, str2), Visitor())
        p = Popen(['bash', '-c', cmd], stderr=STDOUT, stdout=PIPE)
        actual = ''.join(p.stdout.read().rsplit('\r\n'))
        self.assertEquals(expected, actual)

    def test_bash_print_variable(self):
        cseq = '''a = 7
print a'''
        expected = "7"
        cmd = py2bash(cseq, Visitor())
        p = Popen(['bash', '-c', cmd], stderr=STDOUT, stdout=PIPE)
        actual = ''.join(p.stdout.read().rsplit('\r\n'))
        self.assertEquals(expected, actual)


        
if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testName']
    unittest.main()