# -*- Mode: perl; indent-tabs-mode: nil -*-
#
# The contents of this file are subject to the Mozilla Public
# License Version 1.1 (the "License"); you may not use this file
# except in compliance with the License. You may obtain a copy of
# the License at http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS
# IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
# implied. See the License for the specific language governing
# rights and limitations under the License.
#
# The Original Code is the GitId Bugzilla Extension.
#
# The Initial Developer of the Original Code is YOUR NAME
# Portions created by the Initial Developer are Copyright (C) 2013 the
# Initial Developer. All Rights Reserved.
#
# Contributor(s):
#   Graham THE Ollis <plicease@cpan.org>

package Bugzilla::Extension::GitId;

use strict;
use base qw(Bugzilla::Extension);
use Bugzilla::Util qw(html_quote);
use YAML ();

our $VERSION = '0.01';

# See the documentation of Bugzilla::Hook ("perldoc Bugzilla::Hook" 
# in the bugzilla directory) for a list of all available hooks.
sub install_update_db
{
  my ($self, $args) = @_;
}

sub bug_format_comment
{
  my($self, $args) = @_;
  
  push @{ $args->{'regexes'} }, {
    match   => qr{\bgit commit (\S+) ([0-9a-f]{40})\b},
    replace => sub {
      my($args)  = @_;
      my $name   = html_quote $args->{matches}->[0];
      my $git_id = $args->{matches}->[1];
      return qq{git commit <a href="http://foo.com/$name">$name</a> <a href="http://foo.com/$name/$git_id">$git_id</a>};
    },
  };
}

__PACKAGE__->NAME;
