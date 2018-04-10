#!/bin/sh

confDir=/run/openvpn-client/vpngate
[ -d "${confDir}" ] || mkdir "${confDir}"
stat -c %n "${confDir}"/*.conf  || getvpngateconfs.sh '' "${confDir}"
lastConf="$(find "${confDir}" -name '*.conf' -type f | tail -n 1)"
mv -v "${lastConf}" vpngate.conf
