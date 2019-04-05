#!/bin/bash

urlList="${1:-urllist.txt}"

[ -s "${urlList}" ] && wget -i "${urlList}" -q --spider || :
