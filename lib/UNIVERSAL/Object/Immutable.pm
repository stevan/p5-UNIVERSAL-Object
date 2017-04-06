package UNIVERSAL::Object::Immutable;
# ABSTRACT: A useful base class

use strict;
use warnings;

use Carp       ();
use Hash::Util ();
use UNIVERSAL::Object;

our $VERSION   = '0.06';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }

sub BLESS {
    my $self = $_[0]->SUPER::BLESS( $_[1] );

    Carp::croak('Immutable objects must use a HASH ref REPR type, not '.Scalar::Util::reftype($self))
        unless Scalar::Util::reftype($self) eq 'HASH';

    Hash::Util::lock_hash( %$self );
    return $self;
}

1;

__END__

=pod

=head1 SYNPOSIS

    # used exactly as UNIVERSAL::Object is used
    our @ISA = ('UNIVERSAL::Object::Immutable');

=head1 DESCRIPTION

You can use this class in the same manner that you would use
L<UNIVERSAL::Object>, the only difference is that the instances
created will be immutable.

=head2 Why Immutability?

Immutable data structures are unable to be changed after they are
created. By placing and enforcing the guarantee of immutability,
the users of our class no longer need to worry about a while class
of problems that arise from mutable state.

=head2 Immutability is viral

Inheriting from an immutable class will make your subclass also
immutable. This is by design.

=head2 Immutability after the fact

When this class is used at the root of an object hierarchy, all the
subclasses will be immutable. However, if you wish to make an immutable
subclass of a non-immutable class, then you have two choices.

=over 4

=item Multiple Inheritance

Using multiple inheritance, and putting this class first in the list,
we can be sure that the expected version of C<BLESS> is used.

    our @ISA = (
        'UNIVERSAL::Object::Immutable',
        'My::Super::Class'
    );

=item Role Composition

Using the role compositon facilities in the L<MOP> package will result
in C<BLESS> being aliased into the consuming package and therefore have
the same effect as the multiple inheritance.

    our @ISA  = ('My::Super::Class');
    our @DOES = ('UNIVERSAL::Object::Immutable');
    # make sure something performs the role composition ...

=back

=cut




