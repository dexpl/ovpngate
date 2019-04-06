#!/bin/sh

# confFile=vpngate.conf if $countries is unset, vpngate-${countries}.conf
# otherwise
confDir="vpngate${countries:+-${countries}}"
confFile="${confDir}.conf"
until [ -n "${newConfFile}" ]; do
	newConfFile=$(find "${confDir}" -name '*.conf' -type f | shuf -n 1)
	[ -z "${newConfFile}" ] && getvpngateconfs.pl "${countries}" "${confDir}"
done
mv -v "${newConfFile}" "${confFile}"
