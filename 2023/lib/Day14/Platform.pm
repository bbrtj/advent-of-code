package Day14::Platform;

use List::Util qw(max zip);
use Sereal qw(get_sereal_encoder get_sereal_decoder);
use Types::Common -types;

use class;

has field 'size_x' => (
	writer => -hidden,
	default => !!0,
);

has field 'size_y' => (
	writer => -hidden,
	default => !!0,
);

has field 'matrix' => (
	isa => ArrayRef [ArrayRef [Int]],
	writer => -hidden,
	default => sub { [] },
);

has field 'horizontal' => (
	writer => -hidden,
	default => !!1,
);

has field 'encoder' => (
	default => sub {
		get_sereal_encoder();
	},
);

sub set_horizontal ($self)
{
	if (!$self->horizontal) {
		$self->matrix->@* = zip $self->matrix->@*;
	}

	$self->_set_horizontal(!!1);
}

sub set_vertical ($self)
{
	if ($self->horizontal) {
		$self->matrix->@* = zip $self->matrix->@*;
	}

	$self->_set_horizontal(!!0);
}

sub size_primary ($self)
{
	return $self->horizontal ? $self->size_y : $self->size_x;
}

sub add_row ($self, $row)
{
	push $self->matrix->@*, $row;
	$self->_set_size_x(max $self->size_x, scalar $row->@*);
	$self->_set_size_y($self->size_y + 1);
}

sub get_line ($self, $at)
{
	return $self->matrix->[$at];
}

sub set_line ($self, $at, $new_line)
{
	$self->matrix->[$at] = $new_line;
}

sub serialize ($self)
{
	# $self->set_horizontal;
	return $self->encoder->encode($self->matrix);
}

sub deserialize ($self, $matrix_serialized)
{
	my $decoder = get_sereal_decoder;
	$self->_set_matrix($decoder->decode($matrix_serialized));
}

