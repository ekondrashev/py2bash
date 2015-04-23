#!/usr/bin/env python
import random # Get a random number generator.
NTRIALS = 10000 # Enough trials to get an reasonably accurate answer.
NPEOPLE = 30 # How many people in the group?
matches = 0 # Keep track of how many trials have matching birthdays.
for trial in range(NTRIALS): # Do a bunch of trials...
    taken = {} # A place to keep track of which birthdays
    # are already taken on this trial.
    for person in range(NPEOPLE): # Put the peoples birthdays down, one at a time...
        day = random.randint(0, 365) # On a randomly chosen day.
        if day in taken:
            matches += 1 # A match!
            break # No need to look for more than one.
        taken[day] = 1 # Mark the day as taken. 