package class;

use header;

use Import::Into;

require Moo;
require Moo::Role;
require Mooish::AttributeBuilder;
require namespace::autoclean;

use constant HAS_XSCONSTRUCTOR => eval "require MooX::XSConstructor; 1";

sub import ($me, @args)
{
	my $pkg = caller;

	Mooish::AttributeBuilder->import::into($pkg);
	my $class_type = ($args[0] // '') eq -role ? 'Moo::Role' : 'Moo';
	$class_type->import::into($pkg);

	if ($class_type eq 'Moo') {
		MooX::XSConstructor->import::into($pkg)
			if HAS_XSCONSTRUCTOR;
	}

	namespace::autoclean->import(-cleanee => $pkg);

	header->import::into($pkg);
}

