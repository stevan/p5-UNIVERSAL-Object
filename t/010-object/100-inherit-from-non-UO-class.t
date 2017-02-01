#!perl

use strict;
use warnings;

use Test::More qw[no_plan];

BEGIN {
    use_ok('UNIVERSAL::Object');
}

=pod

=cut

{
    package Bar;
    use strict;
    use warnings;

    sub new {
        my $class = shift;
        bless { @_ } => $class;
    }

    sub bar { $_[0]->{bar} }
}

{
    package Foo;
    use strict;
    use warnings;
    our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object', 'Bar') };
    our %HAS; BEGIN { %HAS = (foo => sub { 'FOO' }) };

    sub REPR {
        my ($class, $proto) = @_;
        $class->Bar::new( %$proto );
    }

    sub foo { $_[0]->{foo} }
}

{
    my $o = Foo->new;
    isa_ok($o, 'Foo');
    isa_ok($o, 'UNIVERSAL::Object');
    isa_ok($o, 'Bar');

    is($o->foo, 'FOO', '... the expected slot has the expected value');
    is($o->bar, undef, '... the expected slot has the expected value');
}

{
    my $o = Foo->new( foo => 'BAR' );
    isa_ok($o, 'Foo');
    isa_ok($o, 'UNIVERSAL::Object');
    isa_ok($o, 'Bar');

    is($o->foo, 'BAR', '... the expected slot has the expected value');
    is($o->bar, undef, '... the expected slot has the expected value');
}

{
    my $o = Foo->new( bar => 'BAZ' );
    isa_ok($o, 'Foo');
    isa_ok($o, 'UNIVERSAL::Object');
    isa_ok($o, 'Bar');

    is($o->foo, 'FOO', '... the expected slot has the expected value');
    is($o->bar, 'BAZ', '... the expected slot has the expected value');
}

done_testing;
