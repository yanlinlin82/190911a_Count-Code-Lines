#!/bin/bash

find ~/Workspace/ -type d -name '.git' \
	| while read DIR; do
		(
			echo 1>&2 "Scanning: '$(dirname ${DIR})'"
			cd $(dirname ${DIR})
			git log --pretty=format:"# %ai  %an" --numstat 2>/dev/null
		) \
			| awk '{
				if ($1 == "#") {
					d = $2
					a = $0
					gsub("^.*  ", "", a)
				} else if ($3 != "") {
					OFS = "\t"
					print d, a, $3, $1, $2; # date, author, file, add, del
				}
			}'
	done \
		| awk -F'\t' 'BEGIN {
				OFS = "\t"
				print "date", "ext", "line"
			} NR == 1 || ($2 == "Linlin Yan" && $3 ~ /\.[a-zA-Z]+$/) {
				OFS = "\t"
				ext = $3
				gsub(/^.*\./, ".", ext)
				print $1, ext, $4-$5
			}' \
		| gzip -9 \
		> lines.txt.gz
