package File::HomeDir::Win32;

use 5.006;
use strict;

my %Registry;

use Carp;
use Win32;
use Win32::Security::SID;
use Win32::TieRegistry ( TiedHash => \%Registry );

require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
@ISA = qw(Exporter);

%EXPORT_TAGS = ( 'all' => [ qw( home ) ] );
@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
@EXPORT = qw( home );

$VERSION = '0.01';

sub import {
  no strict 'refs';

  my $caller = caller(0);
  my $stash  = *{$caller."::"};

  if ( (defined &{$stash->{home}}) &&
       (defined &{$stash->{"File::"}->{"HomeDir::"}->{home}}) ) {
    if (@_ > 1) {
      carp "Exporter arguments ignored";
    }
    no warnings 'redefine';
    $stash->{"File::"}->{"HomeDir::"}->{home} = \&home;
    $stash->{home} = \&home;
    return;
  }
  goto &Exporter::import;
}

my %HomeDirs;

sub _find_homedirs {
  %HomeDirs    = ( );

  my $node     = Win32::NodeName;
  my $profiles = $Registry{'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\ProfileList\\'};
  unless ($profiles) {
    # Windows 98
    $profiles = $Registry{'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\ProfileList\\'};  
  }
  unless ($profiles) {
    croak "Fatal error: cannot find profiles in Windows registry";
  }

  foreach my $p (keys %$profiles) {
    if ($p =~ /^(S(?:-\d+)+)\\$/) {
      my $sid_str = $1;
      my $sid = Win32::Security::SID::ConvertStringSidToSid($1);
      my $uid = Win32::Security::SID::ConvertSidToName($sid);
      my $domain = "";
      if ($uid =~ /^(.+)\\(.+)$/) {
	$domain = $1;
	$uid    = $2;
      }
      if ($domain eq $node) {
	my $path = $profiles->{$p}->{ProfileImagePath};
	$path =~ s/\%(.+)\%/$ENV{$1}/eg;
	$HomeDirs{$uid} = $path;
      }
    }
  }  
}

sub home(;$) {
  my $user = $ENV{USERNAME};
  $user = shift if (@_);
  croak "Can\'t use undef as a username" unless (defined $user);

  _find_homedirs(), unless (keys %HomeDirs);

  if (exists $HomeDirs{$user}) {
    return $HomeDirs{$user};
  }
  else {
    return;
  }
}

1;

__END__

=head1 NAME

File::HomeDir::Win32 - Find home directories on Win32 systems

=begin readme

=head1 REQUIREMENTS

This package requires Perl 5.6.0 and following modules (most of which
are not included with Perl):

  Win32::Security::SID
  Win32::TieRegistry

=head1 INSTALLATION

Installation can be done using the traditional Makefile.PL or the newer
Build.PL methods.

Using Makefile.PL:

  perl Makefile.PL
  make test
  make install

(On Windows platforms you should use C<nmake> instead.)

Using Build.PL on systems with L<Module::Build> installed:

  perl Build.PL
  perl Build test
  perl Build install

=end readme

=head1 SYNOPSIS

  use File::HomeDir::Win32;

  print "My dir is ",home()," and root's is ",home('Administrator'),"\n";

=head1 DESCRIPTION

This module provides routines for finding home directories on Win32 systems.
It was designed as a companion to L<File::HomeDir> that overrides the
existing C<home> function, which does not properly locate home directories
on Windows machines.

=for readme stop

To use both modules together:

  use File::HomeDir;

  BEGIN {
    if ($^O eq "MSWin32") {
      eval {
        require File::HomeDir::Win32;
        File::HomeDir::Win32->import();
      };
      die "$@" if ($@); 
    }
  }

The C<home> function should work as normal.

=begin readme

See the module documentation for more details.

=end readme

=for readme continue

=head1 CAVEATS

This module will not work on Windows 95/98/ME systems with no user
profiles enabled.

=head1 SEE ALSO

  File::HomeDir

=head1 AUTHOR

Robert Rothenberg <rrwo at cpan.org>

=head2 Suggestions and Bug Reporting

Feedback is always welcome.  Please use the CPAN Request Tracker at
L<http://rt.cpan.org> to submit bug reports.

=head1 LICENSE

Copyright (c) 2005 Robert Rothenberg. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
