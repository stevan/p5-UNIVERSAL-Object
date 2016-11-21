package UNIVERSAL::Object;
# ABSTRACT: A useful base class

use strict;
use warnings;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

BEGIN {
    eval('use ' . ($] >= 5.010 ? 'mro' : 'MRO::Compat'));
    die $@ if $@;
}

sub new {
    my $class = shift;
       $class = ref $class if ref $class;
    my $proto = $class->BUILDARGS( @_ );
    my $self  = $class->BLESS( $proto );
    $self->can('BUILD') && UNIVERSAL::Object::Util::BUILDALL( $self, $proto );
    return $self;
}

sub BUILDARGS {
    shift;
    if ( scalar @_ == 1 && ref $_[0] ) {
        die '[ARGS] expected a HASH reference but got a ' . $_[0]
            unless ref $_[0] eq 'HASH';
        return +{ %{ $_[0] } };
    }
    else {
        die '[ARGS] expected an even sized list reference but instead got ' . (scalar @_) . ' element(s)'
            unless ((scalar @_) % 2) == 0;
        return +{ @_ };
    }
}

sub BLESS {
    my $class = $_[0];
       $class = ref $class if ref $class;
    my $proto = $_[1];

    die '[ARGS] You must specify an instance prototype as a HASH ref'
        unless $proto && ref $proto eq 'HASH';

    my $self = $class->CREATE( $proto );
    return bless $self => $class;
}

sub CREATE {
    my $class = $_[0];
       $class = ref $class if ref $class;
    my $proto = $_[1];

    die '[ARGS] You must specify an instance prototype as a HASH ref'
        unless $proto && ref $proto eq 'HASH';

    my $self  = {};
    my %slots = $class->SLOTS;

    $self->{ $_ } = exists $proto->{ $_ }
        ? $proto->{ $_ }
        : $slots{ $_ }->( $self, $proto )
            foreach keys %slots;

    return $self;
}

sub SLOTS {
    my $class = $_[0];
       $class = ref $class if ref $class;
    no strict   'refs';
    no warnings 'once';
    return %{$class . '::HAS'};
}

sub DESTROY {
    my $self = $_[0];
    $self->can('DEMOLISH') && UNIVERSAL::Object::Util::DEMOLISHALL( $self );
    return;
}

## Utils

sub UNIVERSAL::Object::Util::BUILDALL {
    my ($self, $proto) = @_;
    foreach my $super ( reverse @{ mro::get_linear_isa( ref $self ) } ) {
        my $fully_qualified_name = $super . '::BUILD';
        $self->$fully_qualified_name( $proto )
            if defined &{ $fully_qualified_name };
    }
}

sub UNIVERSAL::Object::Util::DEMOLISHALL {
    my ($self) = @_;
    foreach my $super ( @{ mro::get_linear_isa( ref $self ) } ) {
        my $fully_qualified_name = $super . '::DEMOLISH';
        $self->$fully_qualified_name()
            if defined &{ $fully_qualified_name };
    }
}

1;

__END__

=pod

=head1 NAME

UNIVERSAL::Object - A useful base class

=head1 SYNOPSIS

    ## Point/Point3D Example

    package Point;
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
        my ($self) = @_;
        @{ $self }{qw[ x y ]} = (0 , 0)
    }

    package Point3D;
    use strict;
    use warnings;

    our @ISA = ('Point');
    our %HAS = (
        %Point::HAS, # inheritance
        z => sub { 0 },
    );

    sub z { $_[0]->{z} }

    sub clear {
        my ($self) = @_;
        $self->SUPER::clear;
        $self->{z} = 0;
    }

    ## Person/Employee Example

    package Person;
    use strict;
    use warnings;

    our @ISA = ('UNIVERSAL::Object');
    our %HAS = (

        ## Required
        # this attribute is required because if
        # it is not supplied, the initialiser below
        # will run, which will die
        name   => sub { die 'name is required' },

        ## Optional w/ Default
        # this attribute has a default value
        age    => sub { 0 },

        ## Optional w/out Default
        # this attribute has no defualt value
        # and is not required, however we need
        # to still have an empty sub since we
        # use that sub to locate the "home" package
        # of a given attribute (useful when
        # attributes are inherited or composed in
        # via roles)
        gender => sub {},
    );

    package Employee;
    use strict;
    use warnings;

    our @ISA = ('Person');
    our %HAS = (
        %Person::HAS, # inheritance ;)
        job_title => sub { die 'job_title is required' },
        manager   => sub {},
    );

=head1 DESCRIPTION

This module provides a protocol for object construction and
destruction that aims to be as simple as possible while still
being complete.

=head1 METHODS

=head2 C<new ($class, @args)>

This is the entry point for object construction, from here the
C<@args> are passed into C<BUILDARGS>.

=head2 C<BUILDARGS ($class, @args)>

This method takes the original C<@args> to the C<new> constructor
and is expected to turn them into a canonical form, which is a
HASH ref of name/value pairs. This form is considered a prototype
candidate for the instance and is then passed to C<BLESS> and
should be a (shallow) copy of what was contained in C<@args>.

=head2 C<BLESS ($class, $proto)>

This method receives the C<$proto> candidate from C<BUILDARGS> and
constructs from it a blessed instance by first calling C<CREATE>
to build an unblessed reference with, then blesses that instance.

This newly blessed instance is then initialized by calling all the
available C<BUILD> methods in the correct (reverse mro) order.

=head2 C<CREATE ($class, $proto)>

This method receives the C<$proto> candidate from C<BLESS> and
constructs from it an unblessed instance using the C<%HAS> hash in
the C<$class>.

=head2 C<BUILD ($self, $proto)>

This is an optional initialization method which recieves the blessed
instance as well as the prototype candidate. There are no restirctions
as to what this method can do other then just common sense.

It is worth noting that because we call all the C<BUILD> methods
found in the object hierarchy, this return values of these methods
are completly ignored.

=head2 C<DEMOLISH ($self)>

This is an optional destruction method, similar to C<BUILD>, all
available C<DEMOLISH> methods are called in the correct (mro) order
by C<DESTROY>.

=head2 C<DESTROY ($self)>

The sole function of this method is to kick off the call to all the
C<DEMOLISH> methods during destruction.

=cut
