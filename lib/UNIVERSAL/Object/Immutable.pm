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

=head1 IDEA

When this is at the root of an object hierarchy, that is fine,
but if you wish to make something immutable and inherit from
another source, then how do you handle this?

=head2 Multiple Inheritance

Simply inherit from this class first so as to ensure that the
expected version of C<BLESS> is used.

    our @ISA = (
        'UNIVERSAL::Object::Immutable',
        'My::Super::Class'
    );

=head2 Role Composition

Role compositon will result in C<BLESS> being aliased in the
consuming package and therefore have the same effect as the
multiple inheritance.

    our @ISA  = ('My::Super::Class');
    our @DOES = ('UNIVERSAL::Object::Immutable');

=cut




