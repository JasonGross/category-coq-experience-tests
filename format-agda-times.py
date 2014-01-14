#!/usr/bin/env python
import fileinput, re

last_time = 0

reg = re.compile('^([0-9\.]+): Finished (.*?)\.$')

print('{')

for line in fileinput.input():
    match = reg.match(line)
    if match:
        now_time, file_name = match.groups()
        print('"%s":{"user":%0.03f},' % (file_name, float(now_time) - last_time))
        last_time = float(now_time)
    else:
        last_time = float(line[:line.index(':')])

print('}')
