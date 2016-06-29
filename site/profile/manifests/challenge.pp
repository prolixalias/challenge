class profile::challenge {

  # debug message to assist in hiera config
  notify { 'configuration_message':
    message => hiera('configuration_message'),
  }

  hiera_include('classes', '')

  file { '/usr/share/nginx/html/challenge':
    ensure  => directory,
    owner   => hiera('vcsrepo::owner_user'),
    group   => hiera('vcsrepo::owner_group'),
    mode    => '0600',
    require => [ Package["nginx"] ],
  }

  package { 'git':
    ensure => installed,
  }
                                                                                                                               
  vcsrepo { "/usr/share/nginx/html/challenge":
    ensure   => latest,
    owner    => hiera('vcsrepo::owner_user'),
    group    => hiera('vcsrepo::owner_group'),
    provider => git,
    source   => hiera('vcsrepo::source'),
    revision => hiera('vcsrepo::branch'),
    require  => [ Package["git"], Service["nginx"] ],
  }

}
