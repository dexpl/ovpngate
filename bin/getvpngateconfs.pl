#!/usr/bin/perl -CS -l

# Fetches OpenVPN configs from vpngate.net
#
# Usage: getvpngateconfs [countries] [path]
#
# countries: a list of ISO country codes separated by comma (i. e. ar,au,bd). If
# given, will fetch configs for servers belonging to those countries only. If
# starting with '!' (i. e. !ar,au,bd), will fetch configs for servers belonging
# to all but those countries. Defaults to empty list (fetch everything).
#
# path: a directory to store what fetched. Defaults to the temporary directory.

use strict;
use warnings;

use File::Spec::Functions;
use File::Temp qw(tempdir);
use LWP::Simple;
use MIME::Base64;

my $vpnGateApiUrl = 'http://www.vpngate.net/api/iphone/';

# Consider the first arg a list of country codes separated by comma (i. e.
# us,jp,kr)
my $countries = shift;

# Consider the second arg a directory to put fetched configs into
my $confdir = canonpath shift;

# Consider the first arg a list of countries to exclude if it begins with ! (i.
# e. !us,jp,kr)
my $excludeCountries = $countries ? $countries =~ s/^!// : 0;
my %countries = map { $_ => 1 if $_ } split ',', $countries;

# Emit a warning if $countries is the sole '!'
warn 'An empty exclusion list excludes nothing!'
  if $excludeCountries && !$countries;

if ($confdir) {
    mkdir $confdir
      || die "Cannot create $confdir ($!), aborting";
} else {
    $confdir = tempdir;
    warn "No result directory given, creating $confdir";
}

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

    mkdir catdir $confdir, $CountryShort;
    if ( open my $fh, '>', catfile $confdir, $CountryShort, "${HostName}.conf" )
    {
        print $fh decode_base64 $OpenVPN_ConfigData_Base64;
        close $fh;
    } else {
        warn "Cannot open file for writing: $!";
    }
}
