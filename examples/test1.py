#! /usr/bin/python -u
# How to use it:
#  julius -quiet -input mic -C julian.jconf 2>/dev/null | ./command.py

import sys
import os

def main_loop(file_object, callback):

    startstring = 'sentence1: <s> '

    endstring = ' </s>'

    while 1:

        line = file_object.readline()

        if not line:

            break

        if 'Missing phones:' in line:

            print 'Error: Missing phonemes for the used grammar file.'

            sys.exit(1)

        if line.startswith(startstring) and line.strip().endswith(endstring):
            callback(line.strip('\n')[len(startstring):-len(endstring)])

def parse(line):

    params = [param.lower() for param in line.split() if param]

    commands = {

        'play': 'rhythmbox-client --play',

        'pause': 'rhythmbox-client --pause',

        'next': 'rhythmbox-client --next',

        'prev': 'rhythmbox-client --previous',

        'show': 'rhythmbox-client --notify',

    }

    if params[1] in commands:

        os.popen(commands[params[1]])


if __name__ == '__main__':

    try:

        main_loop(sys.stdin, parse)

    except KeyboardInterrupt:

        sys.exit(1)