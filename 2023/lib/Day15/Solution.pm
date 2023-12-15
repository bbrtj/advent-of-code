package Day15::Solution;

use builtin qw(indexed);

use class;

with 'Solution';

use constant OP_ADD => '=';
use constant OP_REMOVE => '-';

sub _parse_input ($self, $input = $self->input)
{
	return [map { [split //] } split /,/, $input->[0]];
}

sub get_hash ($self, @chars)
{
	my $current = 0;
	foreach my $char (@chars) {
		$current += ord($char);
		$current *= 17;
		$current %= 256;
	}

	return $current;
}

sub part_1 ($self)
{
	my $parts = $self->_parse_input;
	my $sum = 0;

	foreach my $part ($parts->@*) {
		$sum += $self->get_hash($part->@*);
	}

	return $sum;
}

sub part_2 ($self)
{
	my $parts = $self->_parse_input;
	my %boxes;

	my sub find_by_label ($box, $label) {
		return unless $box;

		foreach my $slot_number (keys $box->@*) {
			if ($box->[$slot_number][0] eq $label) {
				return $slot_number;
			}
		}

		return undef;
	}

	foreach my $part ($parts->@*) {
		my $item = pop $part->@*;
		my $op = (any { $_ eq $item } OP_ADD, OP_REMOVE)
			? $item
			: pop $part->@*
			;

		my $label = join '', $part->@*;
		my $box_number = $self->get_hash($part->@*);

		my $at = find_by_label($boxes{$box_number}, $label);
		if ($op eq OP_ADD) {
			if (defined $at) {
				$boxes{$box_number}[$at] = [$label, $item];
			}
			else {
				push $boxes{$box_number}->@*, [$label, $item];
			}
		}
		elsif ($op eq OP_REMOVE) {
			splice $boxes{$box_number}->@*, $at, 1
				if defined $at;
		}
	}

	my $result = 0;
	foreach my ($box_number, $contents) (%boxes) {
		foreach my ($slot_number, $slot) (indexed $contents->@*) {
			$result += ($box_number + 1) * ($slot_number + 1) * $slot->[1];
		}
	}

	return $result;
}

