#!/bin/bash

urlList="${1:-urllist.txt}"

[ -r "${urlList}" ] && wget -i "${urlList}" -q --spider ${urlcheck_wgetopts} || :
