package Solution;

use Types::Common -types;
use Time::HiRes qw(time);
use Term::ANSIColor;
use builtin qw(trim);

use class -role;

has field '_running_part' => (
	isa => Tuple[PositiveInt, PositiveInt],
	writer => 1,
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

sub day_number ($self)
{
	(ref $self) =~ m/Day(\d+)/;
	return $1;
}

sub _init_part ($self, $part)
{
	$self->_set_running_part([$self->day_number, $part]);

	$self->_clear_input_base;
	$self->_clear_timer;
	$self->_timer;
}

sub _print_greeting ($self)
{
	my ($day, $part) = $self->_running_part->@*;

	say colored("Advent of Code [$day/$part]", 'white');
}

sub _print_test_results ($self, $test_result)
{
	# print test result with coloring
	my $test_color = 'green';
	$test_color = 'red' if ref $test_result;
	$test_color = 'yellow' if !defined $test_result;
	$test_result = ref $test_result
		? "FAIL ($$test_result)"
		: $test_result
			? 'PASS'
			: 'N/A'
	;
	say 'Test result: ' . colored($test_result, $test_color);
}

sub _print_results ($self, $result)
{
	my $time = $self->_timer;
	$self->_clear_timer;
	$time = $self->_timer - $time;

	# print result
	say 'Result: ' . colored($result, 'blue');

	# print time with coloring
	my $time_color = 'green';
	my $threshold = 0.01;
	for (qw(bright_green yellow red)) {
		last if $time < $threshold;
		$threshold *= 10;
		$time_color = $_;
	}
	$time = sprintf colored("%.5fs", $time_color), $time;
	say "Run-time: $time";

	# print empty line to separate parts
	say '';
}

sub _test ($self, $part, $orig)
{
	my $test_result;
	try {
		$self->_set_input_base('test');
		my $result = $self->$orig;

		$self->_set_input_base('test/expected');
		my $expected = $self->input->[0];

		if (trim($result) eq trim($expected)) {
			$test_result = !!1;
		}
		else {
			$test_result = \$result;
		}
	}
	catch ($e) {
		my $file_missing = $e =~ /No data file/;
		$test_result = $file_missing ? undef : !!0;
	}

	return $test_result;
}

foreach my $part (1 .. 2) {
	around "part_$part" => sub ($orig, $self) {
		$self->_init_part($part);
		$self->_print_greeting;

		my $tested = $self->_test($part, $orig);

		$self->_init_part($part);
		$self->_print_test_results($tested);

		my $result;
		try {
			$result = $self->$orig;
		}
		catch ($e) {
			$result = "[exception] $e";
		}

		$self->_print_results($result);
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

	die "No data file in '$base' for day $day part $part";
}

