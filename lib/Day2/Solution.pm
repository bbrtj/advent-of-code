package Day2::Solution;

use List::Util qw(product);

use class;

with 'Solution';

sub _parse_input ($self, $line)
{
	state $game_re = qr{
		Game \s+ (\d+):
	}x;

	state $color_re = qr{
		(\d+) \s+ (red|green|blue)
	}x;

	state $set_re = qr{
		((?: $color_re , \s* )* $color_re ) (?: ; | $)
	}x;

	my %result;
	($result{game}) = $line =~ $game_re;

	while ($line =~ m/$set_re/g) {
		my $set = $1;
		my %set_colors;
		while ($set =~ m/$color_re/g) {
			$set_colors{$2} = ($set_colors{$2} // 0) + $1;
		}
		push $result{sets}->@*, \%set_colors;
	}

	return \%result;
}

sub _is_game_possible ($self, $game, $available)
{
	foreach my $set ($game->{sets}->@*) {
		foreach my ($color, $avail) ($available->%*) {
			next unless defined $set->{$color};
			return !!0 if $set->{$color} > $avail;
		}
	}

	return !!1;
}

sub _get_minimum_possible ($self, $game)
{
	my %minimum;
	foreach my $set ($game->{sets}->@*) {
		foreach my ($color, $got) ($set->%*) {
			$minimum{$color} = $got
				if ($minimum{$color} // 0) < $got;
		}
	}

	return \%minimum;
}

sub run_first ($self)
{
	my @games = map { $self->_parse_input($_) } $self->input->@*;

	my %available = (
		red => 12,
		green => 13,
		blue => 14,
	);

	my $sum = 0;
	foreach my $game (@games) {
		$sum += $game->{game}
			if $self->_is_game_possible($game, \%available);
	}

	$self->output($sum);
}

sub run_second ($self)
{
	my @games = map { $self->_parse_input($_) } $self->input->@*;

	my $sum = 0;
	foreach my $game (@games) {
		my $minimum = $self->_get_minimum_possible($game);
		my @items = $minimum->@{qw(red green blue)};
		$sum += product @items;
	}

	$self->output($sum);
}

