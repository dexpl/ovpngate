#!/usr/bin/awk -f
BEGIN {
	whoIs = "/inet/tcp/0/whois.ripe.net/43"
	print ARGV[1] |& whoIs
	while ((whoIs |& getline) > 0)
		if ($1 == "country:" || $1 == "netname:")
			print($2)
	close(whoIs)
}
