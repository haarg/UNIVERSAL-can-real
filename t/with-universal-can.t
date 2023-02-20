use strict;
use warnings;

use Test::Needs qw(UNIVERSAL::can);

use Test::More;

use UNIVERSAL::can::real qw(real_can);

ok \&UNIVERSAL::can != \&real_can;

{
  package WithOverriddenCan;

  sub can { UNIVERSAL::can(@_) }
}

my @warnings;
local $SIG{__WARN__} = sub {
  push @warnings, join '', @_;
};

my $got = UNIVERSAL::can('WithOverriddenCan', 'can');

is $got, \&WithOverriddenCan::can;
is scalar @warnings, 1;

@warnings = ();
$got = UNIVERSAL::can::real::can('WithOverriddenCan', 'can');
is $got, \&WithOverriddenCan::can;
is scalar @warnings, 0;

done_testing;
