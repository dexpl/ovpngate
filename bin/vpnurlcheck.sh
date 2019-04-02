#!/bin/bash

urlList="${1:-urllist.txt}"

[ -s "${urlList}" ] && wget -A /dev/null -i "${urlList}" -q
