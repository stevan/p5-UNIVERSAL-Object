use strict;
use warnings;
use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
    'NAME'               => 'UNIVERSAL::Object',
    'VERSION'            => '0.01',
    'DISTNAME'           => 'UNIVERSAL-Object',
    'ABSTRACT'           => 'A useful base class',
    'AUTHOR'             => 'Stevan Little',
    'BUILD_REQUIRES'     => {},
    'CONFIGURE_REQUIRES' => {
        'ExtUtils::MakeMaker' => 0
    },
    'EXE_FILES'          => [],
    'LICENSE'            => 'perl',
    'NORECURS'           => 1,
    'PREREQ_PM'          => { 'Test::More' => 0 },
);

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);
