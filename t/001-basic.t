#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

BEGIN {
	use_ok('UNIVERSAL::Object');
}

package Point {
	use strict;
	use warnings;

	our @ISA = ('UNIVERSAL::Object');
	our %HAS = ( 
		x => sub { 0 },
		y => sub { 0 },
	);

	sub x { $_[0]->{x} }
	sub y { $_[0]->{y} }

	sub clear {
		@{ $_[0] }{ qw[ x y ]} = (0 , 0)
	}
}

package Point3D {
	use strict;
	use warnings;

	our @ISA = ('Point');
	our %HAS = ( 
		%Point::HAS,
		z => sub { 0 },
	);

	sub z { $_[0]->{z} }

	sub clear {
		$_[0]->SUPER::clear;
		$_[0]->{z} = 0;
	}
}

subtest '... testing Point::new' => sub {

	my $p = Point->new;
	isa_ok($p, 'Point');
	isa_ok($p, 'UNIVERSAL::Object');

	is($p->x, 0, '... got the value we expected');
	is($p->y, 0, '... got the value we expected');

	$p->{x} = 100;
	$p->{y} = 500;

	is($p->x, 100, '... got the changed value we expected');
	is($p->y, 500, '... got the changed value we expected');
};

subtest '... testing Point3D::new' => sub {

	my $p = Point3D->new;
	isa_ok($p, 'Point');
	isa_ok($p, 'Point3D');
	isa_ok($p, 'UNIVERSAL::Object');

	is($p->x, 0, '... got the value we expected');
	is($p->y, 0, '... got the value we expected');
	is($p->z, 0, '... got the value we expected');

	$p->{x} = 100;
	$p->{y} = 500;
	$p->{z} = 250;

	is($p->x, 100, '... got the changed value we expected');
	is($p->y, 500, '... got the changed value we expected');
	is($p->z, 250, '... got the changed value we expected');
};



done_testing;

1;