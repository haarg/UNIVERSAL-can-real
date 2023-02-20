package UNIVERSAL::can::real;
use strict;
use warnings;

our $VERSION = '0.001001';
$VERSION =~ tr/_//d;

use Exporter (); BEGIN { *import = \&Exporter::import }

our @EXPORT_OK = qw(real_can);

sub can;
sub real_can;

if (defined &UNIVERSAL::can::can && \&UNIVERSAL::can == \&UNIVERSAL::can::can) {
  my $real_can;
  eval {
    require B;
    my $ucan = B::svref_2object(\&UNIVERSAL::can);
    my ($names, @pads) = $ucan->PADLIST->ARRAY;
    for my $idx (0 .. $names->MAX) {
      next
        unless $names->ARRAYelt($idx)->can('PV');

      my $name = $names->ARRAYelt($idx)->PV;
      if (defined $name && $name eq '$orig') {

        $real_can = ${ $pads[0]->ARRAYelt($idx)->object_2svref };
        last;
      }
    }
  };
  if (defined $real_can) {
    *can = $real_can;
  }
  # if we weren't able to fish out the original for some reason, use the
  # internal recursing flag to disable the special behavior
  else {
    my $e;
    {
      local $@;
      eval q{
        sub can {
          local $UNIVERSAL::can::recursing = 1;
          UNIVERSAL::can(@_);
        }
        1;
      } or $e = $@;
    }
    die $e if defined $e;
  }
}
else {
  *can = \&UNIVERSAL::can;
}

*real_can = \&can;

1;
__END__

=head1 NAME

UNIVERSAL::can::real - Access the real UNIVERSAL::can function

=head1 SYNOPSIS

  use UNIVERSAL::can;
  use UNIVERSAL::can::real qw(real_can);

  # no warnings
  real_can('UNIVERSAL::can::real', 'can');

=head1 DESCRIPTION

The L<UNIVERSAL::can> module tries to fix problems with overridden C<can>
methods being improperly ignored. However, sometimes ignoring those overridden
methods is appropriate.

This module gives access to the real core L<UNIVERSAL::can|UNIVERSAL/can>
function, even if the L<UNIVERSAL::can> module has been loaded and replaced it.
