package Util;

use Term::ANSIColor;

use header;

sub print_time ($, $time, %options)
{
	%options = (
		header => 'Run-time',
		time_multiplier => 1,
		%options
	);

	my $time_color = 'green';
	my $threshold = 0.001 * $options{time_multiplier};
	for (qw(bright_green bright_yellow yellow red)) {
		last if $time < $threshold;
		$threshold *= 10;
		$time_color = $_;
	}
	my $time_s = int($time);
	my $time_ms = int($time * 1_000) % 1000;
	my $time_μs = int(($time * 1_000_000)) % 1000;
	$time = sprintf '%ss %3sms %3sμs', $time_s, $time_ms, $time_μs;
	say "$options{header}: " . colored($time, $time_color);
}

