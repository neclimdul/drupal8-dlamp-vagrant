name             "dlamp"
license          "Apache 2.0"
description      "Installs a LAMP + Drush development environment"
version          "1.0.0"

recipe           "dlamp", "Installs a LAMP + Drush development environment"

depends "apt"
depends "apache2"
depends "mysql"
depends "composer"
depends "apqc_php"
depends "vhost"
depends "xdebug"

%w{ ubuntu }.each do |os|
  supports os
end