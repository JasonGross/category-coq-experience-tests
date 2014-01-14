#!/bin/bash
while read i
do
	echo "$(date "+%s"): $i"
done
