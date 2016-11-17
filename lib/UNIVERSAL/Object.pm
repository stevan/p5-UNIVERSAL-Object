package UNIVERSAL::Object;

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
    if ( $self->can('BUILD') ) {
        foreach my $super ( reverse @{ mro::get_linear_isa( $class ) } ) {
            my $fully_qualified_name = $super . '::BUILD';
            $self->$fully_qualified_name( $proto )
                if defined &{ $fully_qualified_name };
        }
    }
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

sub SLOTS {
    my $class = $_[0];
       $class = ref $class if ref $class;
    no strict   'refs'; 
    no warnings 'once'; 
    return \%{$class . '::HAS'};
}

sub CREATE {
    my $class = $_[0];
       $class = ref $class if ref $class;
    my $proto = $_[1];

    die '[ARGS] You must specify an instance prototype as a HASH ref'
        unless $proto && ref $proto eq 'HASH';

    my $self  = {};
    my $slots = $class->SLOTS;

    $self->{ $_ } = exists $proto->{ $_ }
        ? $proto->{ $_ }
        : $slots->{ $_ }->( $self, $proto )
            foreach keys %$slots;

    return bless $self => $class;
}

sub DESTROY {
    my $self = $_[0];
    if ( $self->can('DEMOLISH') ) {
        foreach my $super ( @{ mro::get_linear_isa( Scalar::Util::blessed( $self ) ) } ) {
            my $fully_qualified_name = $super . '::DEMOLISH';
            $self->$fully_qualified_name()
                if defined &{ $fully_qualified_name };
        }
    }
    return;
}

1;

__END__

=pod

=head1 NAME

UNIVERSAL::Object - A useful base class

=head1 SYNOPSIS

    package Point 0.01 {
        use strict;
        use warnings;

        our @ISA = ('UNIVERSAL::Object');
        our %HAS = ( 
            x => sub { 0 },
            y => sub { 0 },
        );

        sub x ($self) { $self->{x} }
        sub y ($self) { $self->{y} }

        sub clear ($self) {
            @{ $self }{qw[ x y ]} = (0 , 0)
        }
    }

    package Point3D 0.01 {
        use strict;
        use warnings;

        our @ISA = ('Point');
        our %HAS = ( 
            %Point::HAS,
            z => sub { 0 },
        );

        sub z ($self) { $self->{z} }

        sub clear ($self) {
            $self->SUPER::clear;
            $self->{z} = 0;
        }
    }

=head1 DESCRIPTION



=cut