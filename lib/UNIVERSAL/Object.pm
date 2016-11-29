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
    my $self  = $class->CREATE( $proto );
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

    return bless $self => $class;
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

=head1 SYNOPSIS

    package Person;
    use strict;
    use warnings;

    our @ISA = ('UNIVERSAL::Object');
    our %HAS = (
        name   => sub { die 'name is required' }, # required in constructor
        age    => sub { 0 },                      # w/ default value
        gender => sub {},                         # no default value
    );

    sub name   { $_[0]->{name}   }
    sub age    { $_[0]->{age}    }
    sub gender { $_[0]->{gender} }

    package Employee;
    use strict;
    use warnings;

    our @ISA = ('Person');
    our %HAS = (
        %Person::HAS, # inheritance :)
        job_title => sub { die 'job_title is required' },
        manager   => sub {},
    );

    sub job_title { $_[0]->{job_title} }
    sub manager   { $_[0]->{manager}   }


=head1 DESCRIPTION

This module provides a protocol for object construction and
destruction that aims to be as simple as possible while still
being complete.

=head2 C<new ($class, @args)>

This is the entry point for object construction, from here the
C<@args> are passed into C<BUILDARGS>.

=head2 C<BUILDARGS ($class, @args)>

This method takes the original C<@args> to the C<new> constructor
and is expected to turn them into a canonical form, which is a
HASH ref of name/value pairs. This form is considered a prototype
candidate for the instance and is then passed to C<CREATE> and
should be a (shallow) copy of what was contained in C<@args>.

=head2 C<CREATE ($class, $proto)>

This method receives the C<$proto> candidate from C<BUILDARGS> and
constructs from it an unblessed instance using the C<%HAS> hash in
the C<$class>, then blesses that instance.

This newly blessed instance is then initialized by calling all the
available C<BUILD> methods in the correct (reverse mro) order.

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
