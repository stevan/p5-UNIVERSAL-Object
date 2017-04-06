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

=cut




