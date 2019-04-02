#!/bin/sh

confFile=vpngate.conf
[ -e "${confFile}" ] && rm "${confFile}"
stat -c %n *.conf  || getvpngateconfs.sh
find . -name '*.conf' -type f | tail -n 1 | xargs -I % mv -v % "${confFile}"
