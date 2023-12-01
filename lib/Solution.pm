package Solution;

use Types::Common -types;
use Time::HiRes qw(time);

use class -role;

has field '_running_part' => (
	isa => Tuple[PositiveInt, PositiveInt],
	writer => 1,
);

has field 'input' => (
	isa => ArrayRef[Str],
	lazy => 'grab_input',
);

has field '_output' => (
	isa => ArrayRef[Str],
	lazy => sub { [] },
	clearer => 1,
);

has field '_timer' => (
	isa => PositiveNum,
	lazy => sub { time },
	clearer => 1,
);

requires qw(run_first run_second);

sub output ($self, $str)
{
	push $self->_output->@*, $str;
}

sub _init_part ($self, $part)
{
	my ($day) = (ref $self) =~ m/Day(\d+)/;
	$self->_set_running_part([$day, $part]);

	$self->_clear_timer;
	$self->_timer;

	$self->_clear_output;
}

before 'run_first' => sub ($self) {
	$self->_init_part(1);
};

before 'run_second' => sub ($self) {
	$self->_init_part(2);
};

after [ qw(run_first run_second) ] => sub ($self) {
	my $time = $self->_timer;
	$self->_clear_timer;

	my ($day, $part) = $self->_running_part->@*;

	my $output = join "\n", $self->_output->@*;
	printf <<~'SUMMARY', $day, $part, $self->_timer - $time, $output;
	Advent of Code
	Day %d, Part %d - took %.5fs
	-------------------------------
	%s

	SUMMARY
};

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

