class profile::master {

  # debug message to assist in hiera config
  notify { 'configuration_message':
    message => hiera('configuration_message'),
  }
  notify { 'message':
    message => hiera('message'),
  }

  hiera_include('classes', '')

  $hiera_yaml = "${::settings::confdir}/hiera.yaml"
  #$hiera_yaml = "/etc/puppetlabs/code-staging/hiera.yaml"

  class { 'hiera':
    hierarchy  => [
      'virtual/%{::virtual}',
      'nodes/%{::hostname}',
      'role/%{::role}',
      'common',
    ],
	eyaml      => true,
	keysdir    => /etc/puppetlabs/code-staging/keys
    hiera_yaml => $hiera_yaml,
    datadir    => '/etc/puppetlabs/code/environments/%{::environment}/hieradata',
    owner      => 'pe-puppet',
    group      => 'pe-puppet',
    notify     => Service['pe-puppetserver'],
  }

  ini_setting { 'puppet.conf hiera_config main section' :
    ensure  => present,
    path    => "${::settings::confdir}/puppet.conf",
    section => 'main',
    setting => 'hiera_config',
    value   => $hiera_yaml,
    notify  => Service['pe-puppetserver'],
  }

  ini_setting { 'puppet.conf hiera_config master section' :
    ensure  => absent,
    path    => "${::settings::confdir}/puppet.conf",
    section => 'master',
    setting => 'hiera_config',
    value   => $hiera_yaml,
    notify  => Service['pe-puppetserver'],
  }

  #remove the default hiera.yaml from the code-staging directory
  #after the next code manager deployment it should be removed
  #from the live codedir
  #file { '/etc/puppetlabs/code-staging/hiera.yaml' :
  #  ensure => absent,
  #}

  #Lay down update-classes.sh for use in r10k postrun_command
  #This is configured via the pe_r10k::postrun key in hiera
  #file { '/usr/local/bin/update-classes.sh' :
  #  ensure => file,
  #  source => 'puppet:///modules/profile/puppetmaster/update-classes.sh',
  #  mode   => '0755',
  #}

  #https://docs.puppetlabs.com/puppet/latest/reference/config_file_environment.html#environmenttimeout
  ini_setting { 'environment_timeout = unlimited':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'main',
    setting => 'environment_timeout',
    value   => 'unlimited',
    notify  => Service['pe-puppetserver'],
  }

  package { ['aws-sdk-core','retries']:
    ensure   => present,
    provider => 'puppet_gem',
  }

  exec { "source_etc_environment":
    provider => shell,
    command  => "cat /etc/environment | while read lines; do export $lines; done",
    before   => Route53_cname_record['master.fullfrontalingenuity.com.'],
  }

  route53_cname_record { 'master.fullfrontalingenuity.com.':
    ensure  => 'present',
    ttl     => '60',
    #values => [ "$::hostname_public" ],
    values  => [ $::facts['ec2_metadata']['public-hostname'] ],
    zone    => "$::domain_public.",
  }

  $aws_instances = hiera('aws_instances')
  create_resources ('ec2_instance', $aws_instances)

}
