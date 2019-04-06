#!/usr/bin/perl -C -l

# Fetches OpenVPN configs from vpngate.net
#
# Usage: getvpngateconfs [countries] [path]
#
# countries: a list of ISO country codes separated by comma (i. e. ar,au,bd). If
# given, will fetch configs for servers belonging to those countries only. If
# starting with '!' (i. e. !ar,au,bd), will fetch configs for servers belonging
# to all but those countries. Defaults to empty list (fetch everything).
#
# path: a directory to store fetched configs. Defaults to the
# 'vpngate-${countries}' (or just 'vpngate' if no countries are given) inside
# current working directory. Will be created if missing.

use strict;
use warnings;

use File::Spec::Functions;
use LWP::Simple;
use MIME::Base64;

my $vpnGateApiUrl   = 'http://www.vpngate.net/api/iphone/';
my $outputDirPrefix = 'vpngate';

# Consider the first arg a list of country codes separated by comma (i. e.
# us,jp,kr)
my $countries = shift // '';

# Consider the second arg a directory to put fetched configs into
my $outputDir = canonpath shift;

die "$countries is not a valid country code list"
  unless $countries =~ /^!?(?:[a-z]{2},?)+$/;

# If no output dir is given set it to vpngate-${countries}
$outputDir = $outputDirPrefix . ( $countries ? "-$countries" : '' )
  unless $outputDir;

# Consider $countries a list of countries to exclude if it begins with ! (i.
# e. !us,jp,kr)
my $excludeCountries = $countries ? $countries =~ s/^!// : 0;
my %countries = map { $_ => 1 if $_ } split ',', $countries;

-d $outputDir
  || mkdir $outputDir
  || die "Cannot create $outputDir ($!), aborting";
-w $outputDir || die "Cannot write into $outputDir, aborting";

foreach ( split $/, get($vpnGateApiUrl) ) {
    next if /^(?:#|\*)/;
    my (
        $HostName,     $IP,
        $Score,        $Ping,
        $Speed,        $CountryLong,
        $CountryShort, $NumVpnSessions,
        $Uptime,       $TotalUsers,
        $TotalTraffic, $LogType,
        $Operator,     $Message,
        $OpenVPN_ConfigData_Base64
    ) = split ',', $_;

    # TODO use Geo::IP
    unless ($CountryShort) {
        warn "Skipping $IP due to its empty country code";
        next;
    }
    $CountryShort = lc($CountryShort);

    # Skip this one if we're either excluding some countries and this one is in
    # exclusion list or including only some countries and this one is not in
    # inclusion list
    # TODO check whether $IP actually belongs to $CountryShort
    next
      if ( ( $excludeCountries && $countries{$CountryShort} )
        || ( %countries && !$excludeCountries && !$countries{$CountryShort} ) );

    mkdir catdir $outputDir, $CountryShort;
    if (
        open my $fh,
        '>', catfile $outputDir,
        $CountryShort, "${HostName}.conf"
      )
    {
        print $fh decode_base64 $OpenVPN_ConfigData_Base64;
        close $fh;
    } else {
        warn "Cannot open file for writing: $!";
    }
}
