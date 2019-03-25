#!/usr/bin/perl -l

use strict;

sub fib {
	my $i = int shift;
	return ($i >= 2 ? fib($i - 1) + fib($i - 2) : $i)
}

my $upto = (@ARGV ? int shift : 0);
map { printf "fib(%2d) = %10d\n", $_, fib($_) } (0..$upto);
