package Day25::Groups;

use class;

has field 'connections' => (
	default => sub { {} },
);

sub add ($self, $from, $to)
{
	push $self->connections->{$from}->@*, $to;
	push $self->connections->{$to}->@*, $from;
}

sub separate_groups ($self, $disconnect_count)
{
	my $connections = $self->connections;
	my %included;
	my sub init_included () {
		state $last_tried = 0;

		%included = ();
		my $item = (keys $connections->%*)[$last_tried++];
		$included{$item} = 1;
		$included{$connections->{$item}[0]} = 1;
	}

	init_included;
	while (1) {
		my %seen;
		foreach my $inc (keys %included) {
			foreach my $conn ($connections->{$inc}->@*) {
				$seen{$conn}++ unless $included{$conn};
			}
		}

		my $added = 0;
		foreach my ($item, $times) (%seen) {
			next unless $times > 1;
			$included{$item} = 1;
			$added++;
		}

		if (!$added) {
			if (keys(%included) == 2) {
				# looks like we did nothing, try anew
				init_included;
			}
			elsif (keys(%included) == keys($connections->%*)) {
				# looks like we ended up including everything, try anew
				init_included;
			}
			elsif (keys(%seen) - $added != $disconnect_count) {
				# this was not the division we were looking for, so add extra items
				foreach my ($item, $times) (%seen) {
					next unless $times == 1;
					$included{$item} = 1;
				}
			}
			else {
				# we're done
				last;
			}
		}
	}

	my $size_1 = keys %included;
	my $size_2 = keys($connections->%*) - $size_1;

	return $size_1 * $size_2;
}

