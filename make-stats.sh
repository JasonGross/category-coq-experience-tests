#!/bin/bash

echo "Unicode characters: $(cat "$@" | grep -o '[^ !"#$%&'"'"'()*+,\./0-9:;<=>?@A-Z[\\^_`a-z{|}~-]' | grep -v ']' | sort | uniq | tr '\n' ' ' | sed s'/ //g')"

echo "Stats: {" | tr '\n' ' '
for i in "$@"
do
    echo "\"$i\":{" | tr '\n' ' '
    echo "'definitions':$(grep '^\s*\(Global\s\+\|Program\s\+\)*\(Definition\|Lemma\|Theorem\|Corollary\|Remark\|Fact\|Proposition\|Example\|Fixpoint\|CoFixpoint\|Inductive\|CoInductive\|Instance\)' "$i" | wc -l)," | tr '\n' ' '
    echo "'lines':$(wc -l < "$i")," | tr '\n' ' '
    echo "'characters':$(wc -c < "$i")," | tr '\n' ' '
    echo "'words':$(wc -w < "$i")," | tr '\n' ' '
    echo "'non-space lines':$(grep -c '^\s*$' "$i")," | tr '\n' ' '
    echo "'.':$(grep -o '\.' "$i" | wc -l)," | tr '\n' ' '
    echo "';':$(grep -o ';' "$i" | wc -l)," | tr '\n' ' '
    echo "}," | tr '\n' ' '
done
echo '}'
