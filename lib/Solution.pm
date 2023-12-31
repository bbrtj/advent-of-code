package Solution;

use Types::Common -types;
use Time::HiRes qw(time);
use Term::ANSIColor;
use builtin qw(trim);
use Util;
use Data::Dumper;

use class -role;

has param 'year' => (
	isa => PositiveInt,
);

has param 'language' => (
	isa => Str,
	default => 'perl',
);

has field '_running_part' => (
	isa => Tuple[PositiveInt, PositiveInt],
	writer => 1,
);

has field 'timer' => (
	writer => -hidden,
);

has field '_input_base' => (
	writer => 1,
	clearer => 1,
	lazy => sub { 'input' },
);

has field 'is_test' => (
	writer => 1,
	default => !!0,
);

requires qw(part_1 part_2);

sub day_number ($self)
{
	(ref $self) =~ m/Day(\d+)/;
	return $1;
}

sub _start_timer ($self)
{
	$self->_set_timer(time);
}

sub _end_timer ($self)
{
	$self->_set_timer(time - $self->timer);
}

sub _init_part ($self, $part)
{
	$self->_set_running_part([$self->day_number, $part]);
	$self->_clear_input_base;
}

sub _print_greeting ($self)
{
	my ($day, $part) = $self->_running_part->@*;
	my $lang = ucfirst lc $self->language;

	say colored('Advent of Code ' . $self->year, 'white');
	say colored("Day $day part $part - $lang", 'white');
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
	# print result
	say 'Result: ' . colored($result, 'blue');

	# print time with coloring
	Util->print_time($self->timer);

	# print empty line to separate parts
	say '';
}

sub _test ($self, $part, $orig)
{
	$self->set_is_test(!!1);
	defer {
		$self->set_is_test(!!0);
	}

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
		chomp $e unless ref $e;
		$test_result = $file_missing ? undef : \"[exception] $e";
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
			$self->_start_timer;
			$result = $self->$orig;
			$self->_end_timer;
		}
		catch ($e) {
			$self->_end_timer;
			$result = "[exception] $e";
		}

		$self->_print_results($result);
	};
}

sub input ($self, $empty_lines = !!0)
{
	my ($day, $part) = $self->_running_part->@*;
	my $base = $self->year . '/' . $self->_input_base;
	my @filenames = (
		"$base/day${day}_part${part}.txt",
		"$base/day${day}.txt",
	);

	foreach my $filename (@filenames) {
		if (open my $fh, '<', $filename) {
			my @lines = readline $fh;

			return $empty_lines
				? [map { chomp; $_ } @lines]
				: [grep { length } map { chomp; $_ } @lines]
				;
		}
	}

	die "No data file in '$base' for day $day part $part";
}

sub debug ($self, $string, $show = !!1)
{
	return unless $show;
	return unless $self->is_test;
	if (ref $string) {
		say Dumper($string);
	}
	else {
		say $string;
	}
}

