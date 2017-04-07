package UNIVERSAL::Object::Immutable;
# ABSTRACT: Another useful base class

use strict;
use warnings;

use 5.008;

use Carp       ();
use Hash::Util ();
use UNIVERSAL::Object;

our $VERSION   = '0.08';
our $AUTHORITY = 'cpan:STEVAN';

our @ISA; BEGIN { @ISA = ('UNIVERSAL::Object') }

sub BLESS {
    my $self = $_[0]->SUPER::BLESS( $_[1] );

    Carp::croak('Immutable objects must use a HASH ref REPR type, not '.$self)
        unless $self =~ /\=HASH\(0x/;

    Hash::Util::lock_hash( %$self );
    return $self;
}

1;

__END__

=pod

=head1 SYNOPSIS

    # used exactly as UNIVERSAL::Object is used
    our @ISA = ('UNIVERSAL::Object::Immutable');

=head1 DESCRIPTION

You can use this class in the same manner that you would use
L<UNIVERSAL::Object>, the only difference is that the instances
created will be immutable.

=head2 Why Immutability?

Immutable data structures are unable to be changed after they are
created. By placing and enforcing the guarantee of immutability,
the users of our class no longer need to worry about a whole class
of problems that arise from mutable state.

=head2 Immutability is semi-viral

Inheriting from an immutable class will make your subclass also
immutable. This is by design.

When an immutable instance references other data structures, they
are not made immutable automatically. This too is by design.

This means that given the following class:

    package Person {
        use strict;
        use warnings;

        our @ISA = ('UNIVERSAL::Object::Immutable');
        our %HAS = (
            given_names => sub { +[] },
            family_name => sub {  '' },
        );
    }

    package Employee {
        use strict;
        use warnings;

        our @ISA = ('Person');
        our %HAS = (
            %Person::HAS,
            job_title => sub { '' },
        );
    }

Any of the following lines would cause an error about modification
of a read-only value because we are trying to change the values
inside the hashes or add new values.

    my $e = Employee->new;
    $e->{family_name} = 'little';
    $e->{family_name} .= 'little';
    $e->{given_names} = [ 'stevan', 'calvert' ];
    $e->{job_title} = 'developer';
    $e->{misspelled_key} = 0;

However, the following would not cause an error because the C<ARRAY>
reference stored in the C<given_names> slot is not itself read-only
and so can be modified in this way.

    my $e = Employee->new;
    push @{ $e->{given_names} } => 'stevan', 'calvert';

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

Using the role composition facilities in the L<MOP> package will result
in C<BLESS> being aliased into the consuming package and therefore have
the same effect as the multiple inheritance.

    our @ISA  = ('My::Super::Class');
    our @DOES = ('UNIVERSAL::Object::Immutable');
    # make sure something performs the role composition ...

=back

=head2 Compatibility Note

This class requires Perl 5.8.0 or later, this is because it
depends on the L<Hash::Util> module, which was first introduced
in that version of Perl. Since this is an optional component,
we have not bumped the version requirement for the entire
distribution, only for this module specifically.

=cut




