import unittest
from main import py2bash
from py2bash.optimized.memory.node import Visitor
from subprocess import Popen, PIPE, STDOUT


class Test(unittest.TestCase):


    def test_shell_for_loop_seq_both_boundaries(self):
        cmd = py2bash('''for i in range(0, 5):
    print i''', Visitor())
        expected = '''0
1
2
3
4
'''
        p = Popen(['bash', '-c', cmd], stderr=STDOUT, stdout=PIPE)
        actual = p.stdout.read()
        self.assertEquals(expected, actual)
    
    def test_shell_for_loop_seq_end_only(self):
        cmd = py2bash('''for i in range(5):
    print i''', Visitor())
        expected = '''0
1
2
3
4
'''
        p = Popen(['bash', '-c', cmd], stderr=STDOUT, stdout=PIPE)
        actual = p.stdout.read()
        self.assertEquals(expected, actual)

    def test_shell_for_loop_seq_var_as_end(self):
        cmd = py2bash('''end=5
for i in range(end):
    print i''', Visitor())
        expected = '''0
1
2
3
4
'''
        p = Popen(['bash', '-c', cmd], stderr=STDOUT, stdout=PIPE)
        actual = p.stdout.read()
        self.assertEquals(expected, actual)

    def test_shell_for_loop_with_step(self):
        cmd = py2bash('''end=5
for i in range(0, end, 2):
    print i''', Visitor())
        expected = '''0
2
4
'''
        p = Popen(['bash', '-c', cmd], stderr=STDOUT, stdout=PIPE)
        actual = p.stdout.read()
        self.assertEquals(expected, actual)

    @unittest.skip("Second argument of cycle is incorrectly converted.")
    def test_shell_descending(self):
        cmd = py2bash('''end=5
for i in range(end, 0, -2):
    print i''', Visitor())
        expected = '''5
3
1
'''
        p = Popen(['bash', '-c', cmd], stderr=STDOUT, stdout=PIPE)
        actual = p.stdout.read()
        self.assertEquals(expected, actual)

if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testName']
    unittest.main()