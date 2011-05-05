#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use utf8;
use Hiratara::Timecard;

binmode STDOUT, ':utf8';

my ($tsv_file, $yyyymm) = @ARGV;
my ($year, $month) = $yyyymm =~ /^(\d{4})(\d{2})$/;

my $tc = Hiratara::Timecard->new(
	tsv => $tsv_file, year => $year, month => $month
);

print "【日付】\n";
print $tc->calendar_section;
print "【時間】\n";
print $tc->time_section;
