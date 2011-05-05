#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/lib";
use local::lib "$FindBin::Bin/extlib";
use Encode ();
use CGI;
use Time::Piece;
use Time::Seconds qw/ONE_MONTH/;
use Hiratara::Timecard;

sub main {
	my ($cgi) = @_;
	my $last_month = Time::Piece->new(time - ONE_MONTH);

	my $year = $last_month->year;
	my $month = $last_month->mon;

	return <<__HTML__
<form action="." method="POST">
<input name="year" value="$year">年<input name="month" value="$month">月<br>
<br>
<textarea name="tsv" rows="31"></textarea>
<input type="submit">
</form>
__HTML__
}

sub post {
	my ($cgi) = @_;

	my ($tsv_file, $yyyymm) = @ARGV;
	my ($year, $month) = $yyyymm =~ /^(\d{4})(\d{2})$/;

	my $tc = Hiratara::Timecard->new(
		tsv => \($cgi->param("tsv")), 
		year => $cgi->param("year"), 
		month => $cgi->param("month"), 
	);

	return join("", 
		"【日付】\n", $tc->calendar_section,
		"【時間】\n", $tc->time_section
	) => "text/plain; charset=UTF-8";
}


my $cgi = CGI->new;
my $handler = $cgi->request_method ne 'POST' ? \&main : \&post;

my ($body, $type) = eval { $handler->($cgi) };
if ($@) {
	print $cgi->header("text/plain");
	print $@;
} else {
	print $cgi->header($type || "text/html; charset=utf8");
	print Encode::encode_utf8($body);
}
