#!/bin/sh

# confFile=vpngate.conf if $countries is unset, vpngate-${countries}.conf
# otherwise
confDir=vpngate${countries:+-${countries}}
confFile=${confDir}.conf
[ -e "${confFile}" ] && rm "${confFile}"
stat -c %n *.conf  || getvpngateconfs.pl
find ${confDir} -name '*.conf' -type f | shuf -n 1 | xargs -I % mv -v % "${confFile}"
