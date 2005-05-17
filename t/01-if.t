#!/usr/bin/perl

use strict;

use Test::More;

plan skip_all => "for internal use";

# use File::HomeDir;
# use if ($^O eq "MSWin32"), "File::HomeDir::Win32";

plan tests => 5;

ok( defined home(), "home defined");
ok( home() eq home($ENV{USERNAME}), "home = home(username)");
ok( -d home(), "home exists");

{
  ok( $~{''} eq home(), "\$~{} = home(username)");
  ok( $~{$ENV{USERNAME}} eq home(), "\$~{} = home(username)");
}


