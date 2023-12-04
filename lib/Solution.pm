package Solution;

use Types::Common -types;
use Time::HiRes qw(time);
use Term::ANSIColor;

use class -role;

has field '_running_part' => (
	isa => Tuple[PositiveInt, PositiveInt],
	writer => 1,
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

has field '_input_base' => (
	writer => 1,
	clearer => 1,
	lazy => sub { 'input' },
);

requires qw(part_1 part_2);

sub output ($self, $str)
{
	push $self->_output->@*, $str;
}

sub _init_part ($self, $part)
{
	my ($day) = (ref $self) =~ m/Day(\d+)/;
	$self->_set_running_part([$day, $part]);

	$self->_clear_input_base;
	$self->_clear_output;
	$self->_clear_timer;
	$self->_timer;
}

sub _deinit_part ($self, $test_result)
{
	my $time = $self->_timer;
	$self->_clear_timer;
	$time = $self->_timer - $time;

	# print banner
	say colored('Advent of Code', 'white');

	# print day and part number
	my ($day, $part) = $self->_running_part->@*;
	print "Day $day, Part $part - took ";

	# print time with coloring
	my $time_color = 'green';
	my $threshold = 0.1;
	for (qw(bright_green bright_yellow yellow bright_red red)) {
		last if $time < $threshold;
		$threshold *= 2;
		$time_color = $_;
	}
	printf colored("%.5fs\n", $time_color), $time;

	# print test result with coloring
	my $test_color = 'green';
	$test_color = 'red' if !$test_result;
	$test_color = 'yellow' if !defined $test_result;
	$test_result = $test_result
		? 'PASS'
		: defined $test_result
			? 'FAIL'
			: 'N/A'
	;
	say 'Test: ' . colored($test_result, $test_color);

	# print separator and actual result
	say colored('-------------------------------', 'white');
	say join "\n", $self->_output->@*;

	# print empty line to separate parts
	say '';
}

sub _test ($self, $part, $orig)
{
	my $result;
	try {
		$self->_set_input_base('test');
		$self->$orig;

		$self->_set_input_base('test/expected');
		my @expected = $self->input->@*;
		my @output = $self->_output->@*;

		$result = @expected == @output;
		$result &&= $expected[$_] eq $output[$_]
			for keys @expected;
	}
	catch ($e) {
		$result = undef;
	}

	return $result;
}

foreach my $part (1 .. 2) {
	around "part_$part" => sub ($orig, $self) {
		$self->_init_part($part);
		my $tested = $self->_test($part, $orig);
		$self->_init_part($part);
		$self->$orig;
		$self->_deinit_part($tested);
	};
}

sub input ($self)
{
	my ($day, $part) = $self->_running_part->@*;
	my $base = $self->_input_base;
	my @filenames = (
		"$base/day${day}_part${part}.txt",
		"$base/day${day}.txt",
	);

	foreach my $filename (@filenames) {
		if (open my $fh, '<', $filename) {
			my @lines = readline $fh;

			return [grep { length } map { chomp; $_ } @lines];
		}
	}

	die "couldn't get $base data for day $day part $part";
}

