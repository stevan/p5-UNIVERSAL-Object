package parent;
use strict;
use vars qw($VERSION);
$VERSION = '0.237';

sub import {
    my $class = shift;

    my $inheritor = caller(0);

    my $has; 
    $has = pop @_ if ref $_[-1] eq 'HASH';

    if ( @_ and $_[0] eq '-norequire' ) {
        shift @_;
    } else {
        for ( my @filename = @_ ) {
            s{::|'}{/}g;
            require "$_.pm"; # dies if the file is not found
        }
    }

    {
        no strict 'refs';
        push @{"$inheritor\::ISA"}, @_; # dies if a loop is detected

        if ( $has ) {
            no warnings 'once';
            %{"$inheritor\::HAS"} = (
                (map { %{"$_\::HAS"} } @_),
                %$has
            );
        }
    };
};

1;