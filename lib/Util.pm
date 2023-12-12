package Util;

use Term::ANSIColor;
use Exporter qw(import);

use header;

our @EXPORT_OK = qw(
	parallel_map
);

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

sub parallel_map :prototype(&@) ($sub, @items)
{
	my @pids;
	my @handles;
	my $forks = 8;

	# set up forks
	for my $fork_no (0 .. $forks - 1) {
		my $pid = open(my $handle, "-|")
			// die "Can't fork: $!";

		if ($pid) {
			# parent
			push @pids, $pid;
			push @handles, $handle;
		}
		else {
			# child
			my @results;
			for (my $i = $fork_no; $i < @items; $i += $forks) {
				local $_ = $items[$i];
				push @results, $sub->();
			}

			say join "\x00", @results;
			exit;
		}
	}

	# gather results
	for my $fork_no (0 .. $forks - 1) {
		my $output = readline $handles[$fork_no];
		chomp $output;
		close $handles[$fork_no] or die "Can't close: $!";

		my $last = $fork_no;
		foreach my $result (split /\x00/, $output) {
			$items[$last] = $result;
			$last += $forks;
		}

		waitpid $pids[$fork_no], 0;
	}

	return @items;
}

