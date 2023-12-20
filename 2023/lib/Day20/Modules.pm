package Day20::Modules;

use builtin qw(weaken);
use Math::Utils qw(lcm);

use class;

has field 'modules' => (
	default => sub { {} },
);

has field 'sent_low' => (
	default => 0,
);

has field 'sent_high' => (
	default => 0,
);

has field 'presses' => (
	writer => 1,
	default => 0,
);

has field 'finished_at' => (
	writer => 1,
	default => 0,
);

use constant START_MODULE => 'broadcaster';
use constant START_SIGNAL => 0;
use constant TYPE_FLIPFLOP => '%';
use constant TYPE_CONJUNCTION => '&';

sub _inc ($self, $signal)
{
	$signal ? $self->{sent_high}++ : $self->{sent_low}++;
	return;
}

sub _handle_plain ($module, $signal_from, $signal)
{
	return $signal;
}

sub _handle_flipflop ($module, $signal_from, $signal)
{
	if ($signal == 0) {
		my $state = $module->{state};
		$module->{state} = !$module->{state};
		return $state ? 0 : 1;
	}
	else {
		return undef;
	}
}

sub _handle_conjunction ($module, $signal_from, $signal)
{
	$module->{memory}{$signal_from} = $signal;
	if (all { $_ == 1 } values $module->{memory}->%*) {
		return 0;
	}
	else {
		return 1;
	}
}

sub _init_type ($self, $type)
{
	if (!$type) {
		return (handler => \&_handle_plain);
	}
	if ($type eq TYPE_FLIPFLOP) {
		return (state => !!0, handler => \&_handle_flipflop);
	}
	elsif ($type eq TYPE_CONJUNCTION) {
		return (memory => {}, handler => \&_handle_conjunction);
	}
	else {
		die "unknown type $type";
	}
}

sub add ($self, $type, $label, $connections)
{
	$self->modules->{$label} = {
		type => $type,
		connections => $connections,
		$self->_init_type($type),
	};
}

sub finalize ($self)
{
	my $modules = $self->modules;
	my %inputs;

	foreach my ($label, $module) ($modules->%*) {
		foreach my $conn ($module->{connections}->@*){
			push $inputs{$conn}->@*, $label;
		}
	}

	foreach my ($label, $connections_from) (%inputs) {
		my $module = $modules->{$label};

		if (($module->{type} // '') eq TYPE_CONJUNCTION) {
			$module->{memory}->%* = map { $_ => 0 } $connections_from->@*
		}
	}
}

sub run ($self)
{
	my $modules = $self->modules;
	my @current = map { [$_, START_MODULE, START_SIGNAL] } $modules->{(START_MODULE)}{connections}->@*;
	$self->_inc(START_SIGNAL);
	$self->set_presses($self->presses + 1);

	while (@current > 0) {
		my @new;

		### loop through current states
		foreach my $item (@current) {
			my ($label, $last_label, $signal) = $item->@*;
			### loop: "$last_label -$signal-> $label"

			my $module = $modules->{$label};
			$self->_inc($signal);

			next unless defined $module;
			my $output = $module->{handler}->($module, $last_label, $signal);
			if (defined $output) {
				push @new, map { [$_, $label, $output] } $module->{connections}->@*;
			}
		}

		@current = @new;
	}
}

sub add_rx ($self)
{
	weaken $self;
	my %encountered;

	$self->modules->{rx} = {
		type => undef,
		connections => [],
		handler => sub ($module, $last_label, $signal) {
			my $memory = $self->modules->{$last_label}{memory};
			foreach my ($label, $value) ($memory->%*) {
				$encountered{$label} = $self->presses
					if !defined $encountered{$label} && $value == 1;
			}

			if (keys $memory->%* == keys %encountered) {
				$self->set_finished_at(lcm values %encountered);
			}
		},
	};
}

