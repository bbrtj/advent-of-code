package Day8::Solution;

use Q::S::L qw(superpos fetch_matches);
use Math::BigInt try => 'GMP';

use class;

with 'Solution';

sub _parse_input ($self, $input = $self->input)
{
	my @instruction;
	my %map;

	foreach my $line ($input->@*) {
		if (!@instruction) {
			@instruction = map { $_ eq 'R' } split //, $line;
		}
		elsif ($line =~ m{(\w+) = \((.*)\)}) {
			$map{$1} = [split /,\s*/, $2];
		}
	}

	return (\@instruction, \%map);
}

sub get_number_of_cycles ($self, $instruction, $map, $from, $to_re)
{
	my $current = $from;
	my $instruction_size = $instruction->@*;
	my $steps = 0;

	while ($current !~ $to_re) {
		my $instruction_ind = $steps % $instruction_size;

		$current = $map->{$current}[$instruction->[$instruction_ind]];
		$steps += 1;
	}

	return $steps;
}

sub part_1 ($self)
{
	my ($instruction, $map) = $self->_parse_input;
	return $self->get_number_of_cycles($instruction, $map, 'AAA', qr/ZZZ/);
}

sub part_2 ($self)
{
	my ($instruction, $map) = $self->_parse_input;
	my $all_starting = fetch_matches { superpos([keys $map->%*])->compare(sub { $_[0] =~ /A$/ }) };

	my $lcm = Math::BigInt->new(1);
	foreach my $starting ($all_starting->states->@*) {
		$lcm = $lcm->blcm(
			$self->get_number_of_cycles($instruction, $map, $starting->value, qr/Z$/)
		);
	}

	return $lcm;
}

