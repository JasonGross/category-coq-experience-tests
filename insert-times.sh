#!/bin/bash
while read i
do
	echo "$(date "+%s.%N"): $i"
done
