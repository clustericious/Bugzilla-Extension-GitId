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

use warnings;
use strict;
use v5.10;
use base qw(Bugzilla::Extension);
use Bugzilla::Util qw(html_quote);
use File::stat qw( stat );
use YAML ();

our $VERSION = '0.03';

sub _config
{
  state $config;
  state $filename = $ENV{BUGZILLA_EXTENSION_GITID_CONF} // '/etc/gitid.yml';
  state $timestamp;
  
  my $new_timestamp = eval { stat($filename)->mtime };
  
  if((!defined $config) || $new_timestamp != $timestamp)
  {
    $config = eval { YAML::LoadFile($filename) };
    return {} if $@;
    $timestamp = $new_timestamp;
  }
  
  return $config;
}

sub bug_format_comment
{
  my($self, $args) = @_;
  
  push @{ $args->{'regexes'} }, {
    match   => qr{\bgit (commit|branch|tag) (\S+) (\S+)},
    replace => sub {
      my $match    = shift->{matches};
      my $type     = $match->[0];
      my $ci       = html_quote $match->[1];
      my $ref      = html_quote $match->[2];
      my $tmpl     = _config->{url}->{$ci}->{$type};
      my $repo_url = _config->{url}->{$ci}->{repo};
      return qq{git $type $ci $ref [ not found ]} unless defined $repo_url && defined $tmpl;
      my $ref_url  = sprintf $tmpl, $ref;
      return qq{git $type <a href="$repo_url" target="_blank">$ci</a> <a href="$ref_url" target="_blank">$ref</a>};
    },
  };
}

__PACKAGE__->NAME;
