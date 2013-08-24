exec {
  "apt-get update":
  path => "/usr/bin"
}

# manage_package_repo => true will satisfy apt_postgresql_org
# include postgresql::package_source::apt_postgresql_org

class { 'postgresql':
  version => '9.2',
  manage_package_repo => true,
  charset => 'UTF8',
  locale  => 'en_US.UTF-8'
}

class { 'postgresql::server':

}

postgresql::db { 'all_the_badges':
  user     => 'all_the_badges',
  password => ''
}

rbenv::install { "vagrant":
  group => 'vagrant',
  home  => '/home/vagrant'
}

rbenv::compile { "2.0.0-p247":
  user =>   'vagrant',
  group => 'vagrant',
  home  => '/home/vagrant'
}