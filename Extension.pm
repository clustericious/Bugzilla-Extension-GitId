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

=head1 NAME

Bugzilla::Extension::GitId

=head1 SYNOPSIS

Unpack this extension into your bugzilla extension directory:

 % cd $BUGZILLA/extensions
 % git clone https://github.com/plicease/Bugzilla-Extension-GitId.git GitId

Create a /etc/gitid.yml file that configures the extension

 ---
 url:
   # this example works for github
   # this example uses the GitId extension's git repo
   Bugzilla-Extension-GitId:
     repo: https://github.com/plicease/Bugzilla-Extension-GitId
     # for commit %s is replaced by the git commit id
     commit: https://github.com/plicease/Bugzilla-Extension-GitId/commit/%s
     # for branch %s is replaced by the branch name
     branch: https://github.com/plicease/Bugzilla-Extension-GitId/tree/%s
     # for tag %s is replaced by the tag name
     tag: https://github.com/plicease/Bugzilla-Extension-GitId/tree/%s

If you don't have write access to /etc/gitid.yml, and set
BUGZILLA_EXTENSION_GITID_CONF in your httpd.conf:

 SetEnv BUGZILLA_EXTENSION_GITID_CONF /home/ollisg/etc/gitid.yml

=head1 DESCRIPTION

This extension adds links for comments like these:

 git commit Bugzilla-Extension-GitId 09212c6c6f34733552e6b5970353c4dfea3cf720
 git tag Bugzilla-Extension-GitId 0.03
 git branch Bugzilla-Extension-GitId master

=head1 SEE ALSO

L<Bugzilla>

=head1 AUTHOR

Graham Ollis <plicease@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This software is licensed under the Mozilla Public License Version 1.1

=cut

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
