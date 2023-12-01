package Solution;

use Types::Common -types;

use class;

has field '_running_part' => (
	isa => Tuple[PositiveInt, PositiveInt],
	writer => 1,
);

has field 'input' => (
	isa => ArrayRef[Str],
	lazy => 'grab_input',
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
	my @filenames = (
		"input/day${day}_part${part}.txt",
		"input/day${day}.txt",
	);

	foreach my $filename (@filenames) {
		if (open my $fh, '<', $filename) {
			my @lines = readline $fh;

			return [grep { length } map { chomp; $_ } @lines];
		}
	}

	die "couldn't get input for day $day part $part";
}

