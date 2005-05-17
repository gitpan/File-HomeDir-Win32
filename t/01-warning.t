#!/usr/bin/perl

use strict;

package Foo::Bar;

use Test::More;
use Test::Warn;

plan tests => 8;

use_ok('File::HomeDir');

warning_is { use_ok('File::HomeDir::Win32') } undef,
  "no warning on load";

ok( defined home(), "home defined");
ok( home() eq home($ENV{USERNAME}), "home = home(username)");
ok( -d home(), "home exists");

{
  local $TODO = "File::HomeDir bugs?";
  ok( $~{''} eq home(), "\$~{} = home(username)");
  ok( $~{$ENV{USERNAME}} eq home(), "\$~{} = home(username)");
}

package main;

use strict;


