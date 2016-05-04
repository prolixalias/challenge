## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# Disable filebucket by default for all File resources:
#http://docs.puppetlabs.com/pe/latest/release_notes.html#filebucket-resource-no-longer-created-by-default
File { backup => false }

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

### master
#node /^master*$/ {
#  include ::role::master
#}

### localdev master
node /^master.local*$/ {

class { 'gitlab':
  external_url => 'http://master.local',
  gitlab_rails => {
    'webhook_timeout' => 10,
    'gitlab_default_theme' => 2,
  },
  logging      => {
    'svlogd_size' => '200 * 1024 * 1024',
  },
}

  pe_role { 'delete':
    ensure => absent,
  }

  pe_role { 'Architecture':
    ensure      => present,
    description => 'Architecture team',
    permissions => [{"object_type" => "tokens", "action" => "override_lifetime", "instance" => "*"},{"object_type" => "environment", "action" => "deploy_code", "instance" => "*"},],
  }

  pe_user { 'delete_this_user':
    ensure       => 'present',
    display_name => 'Delete Me',
    password     => 'password',
    email        => 'delete@me',
    role_ids     => ['1'],
  }

  #pe_user { 'paul':
  #  ensure       => present,
  #  display_name => 'Paul Talbot',
  #  password     => 'password',
  #  email        => 'paul@autostructure.io',
  #  role_ids     => ['1'],
  #}

  #pe_user { 'bryan':
  #  ensure       => present,
  #  display_name => 'Bryan Belanger',
  #  password     => 'password',
  #  email        => 'bryan@autostructure.io',
  #  role_ids     => ['1'],
  #}

}


### default
node default {
  #incude a role on any node that specifies it's role via a trusted fact at provision time
  #https://docs.puppetlabs.com/puppet/latest/reference/lang_facts_and_builtin_vars.html#trusted-facts
  #https://docs.puppetlabs.com/puppet/latest/reference/ssl_attributes_extensions.html#aws-attributes-and-extensions-population-example

  #if !empty( $trusted['extensions']['pp_role'] ) {
  #  include "role::${trusted['extensions']['pp_role']}"
  #}

  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }

  # classes from hiera
  hiera_include('classes', [])
}
