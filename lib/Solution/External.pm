package Solution::External;

use Types::Common -types;
use Cwd;
use IPC::Open2;

use class;

with 'Solution';

has param 'language' => (
	isa => Str,
);

has param 'day' => (
	isa => PositiveInt,
);

has field 'pids' => (
	isa => ArrayRef,
	default => sub { [] },
);

around 'day_number' => sub ($orig, $self) {
	return $self->day;
};

sub solution_path ($self)
{
	my $lang = $self->language;
	my $day = $self->day;
	return "external/$lang/$day";
}

sub BUILD ($self, $args)
{
	my $path = $self->solution_path;
	die "no such solution $path"
		unless -d $path;

	my $old_cwd = getcwd;
	chdir $path;
	my $pid = open2 my $fh_out, my $fh_in, 'make 2>&1';
	waitpid $pid, 0;

	# got error?
	if ($? >> 8) {
		print readline $fh_out;
		die 'Error running make';
	}

	chdir $old_cwd;
}

sub DEMOLISH ($self, $)
{
	waitpid $_, 0
		for $self->pids->@*;
}

sub run_external ($self, $part)
{
	my $pid = open2 my $fh_out, my $fh_in, $self->solution_path . '/solution', $part;
	push $self->pids->@*, $pid;

	say {$fh_in} $_
		for $self->input->@*;

	my $output;
	close $fh_in;

	# reset timer, so that less overhead will be measured
	$self->_start_timer;
	sysread $fh_out, $output, 2 << 16;

	return $output;
}

sub part_1 ($self)
{
	return $self->run_external(1);
}

sub part_2 ($self)
{
	return $self->run_external(2);
}

