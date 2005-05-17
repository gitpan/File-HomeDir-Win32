#!/usr/bin/perl

use strict;

use Test::More;

BEGIN {
  eval {
    require File::HomeDir;
    File::HomeDir->import();
  };
  plan skip_all => "File::HomeDir not installed" if ($@);
}

plan tests => 5;

BEGIN {
  if ($^O eq "MSWin32") {
    eval {
      require File::HomeDir::Win32;
      File::HomeDir::Win32->import();
    };
    die "$@" if ($@); 
  }
}

ok( defined home(), "home defined");
ok( home() eq home($ENV{USERNAME}), "home = home(username)");
ok( -d home(), "home exists");

{
  ok( $~{''} eq home(), "\$~{} = home(username)");
  ok( $~{$ENV{USERNAME}} eq home(), "\$~{} = home(username)");
}


