package Hiratara::Timecard;
use strict;
use warnings;
use utf8;
use base qw/Class::Accessor::Fast/;
use Time::Piece;
use Time::Seconds qw/ONE_DAY/;

our $VERSION = '0.01';

__PACKAGE__->mk_accessors(qw/tsv piece _date_list _timecard/);

sub copy_piece($) { Time::Piece->new($_[0]->epoch) }

sub key_piece($) { $_[0]->strftime('%Y/%m/%d') }

sub new {
	my $class = shift;
	my %param = @_;

	my $year = delete $param{year} or die;
	my $month = delete $param{month} or die;

	my $piece = Time::Piece->strptime("$year/$month", "%Y/%m");

	$class->SUPER::new({piece => $piece, %param});
}

sub date_list {
	my $self = shift;

	unless ($self->_date_list) {
		my @date_list;
		my $this_month = $self->piece->month;
		my $cur_date = copy_piece($self->piece);

		while ($cur_date->mon == $self->piece->mon) {
			push @date_list, copy_piece($cur_date);
			$cur_date += ONE_DAY;
		}

		$self->_date_list(\@date_list);
	}

	return @{$self->_date_list};
}

sub timecard {
	my $self = shift;

	unless ($self->_timecard) {
		my %timecard;
		my @date_list = $self->date_list;

		open my $in, '<', $self->tsv or die "$!: " . $self->tsv;
		while (<$in>) {
			s/(\r?\n|\r)$//;  # chomp
			my ($from, $to) = split /\t/, $_, 2;
			my $date = shift @date_list or die "invalid tsv data";
			$timecard{key_piece $date} = [$from => $to];
		}

		$self->_timecard(\%timecard)
	}

	$self->_timecard;
}

sub calendar_section {
	my $self = shift;

	my @bodies;
	for my $d ($self->date_list) {
		push @bodies, join "\t", ($d->mday == 1 ? $d->mon : ''), 
		                         $d->strftime('%Y/%m/%d');
	}

	return join '', map {$_, "\n"} @bodies;
}

sub time_section {
	my $self = shift;

	my $timecard = $self->timecard;

	my @bodies;
	for my $d ($self->date_list) {
		my ($from, $to) = @{ $timecard->{key_piece $d} };
		my $time_shift = $from ? '9:00' : '';
		my $work_style = $from ? '' : '休み';
		push @bodies, join "\t", $time_shift, $work_style, 
		                         $from || '', $to || '';
	}

	return join '', map {$_, "\n"} @bodies;
}

1;
__END__

=head1 NAME

Hiratara::Timecard -

=head1 SYNOPSIS

  use Hiratara::Timecard;

=head1 DESCRIPTION

Hiratara::Timecard is

=head1 AUTHOR

hiratara E<lt>hiratara@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
