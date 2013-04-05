#!/bin/bash
. assert.sh
cond=0
a=5
b=4
#condition="$a -lt $b"
condition="0 -eq 0"
assert "$condition" $LINENO


if [ $a -ne $b ]; then
	echo woot
fi
