package Solution;

use Types::Common -types;
use autodie;

use class;

has field '_running_part' => (
	isa => Tuple[PositiveInt, PositiveInt],
	writer => 1,
);

sub _init_part ($self, $part)
{
	my ($day) = (ref $self) =~ m/Day(\d+)/;
	$self->_set_running_part([$day, $part]);

	print <<~GREETINGS;
	Advent of Code solution for day $day, part $part
	---------------------------------------------
	GREETINGS
}

sub run_first ($self)
{
	$self->_init_part(1);
}

sub run_second ($self)
{
	$self->_init_part(2);
}

sub grab_input ($self, $wanted_part = undef)
{
	my ($day, $part) = $self->_running_part->@*;
	$part = $wanted_part if $wanted_part;
	my $filename = "input/day${day}_part${part}.txt";

	open my $fh, '<', $filename;
	my @lines = readline $fh;

	return [grep { length } map { chomp; $_ } @lines];
}

