execute "initial-sudo-apt-get-update" do
  command "apt-get update && apt-get -y upgrade"
end

# Making apache run as the vagrant user simplifies things when you ssh in
node.set["apache"]["user"] = "vagrant"
node.set["apache"]["group"] = "vagrant"

require_recipe "apt"
require_recipe "networking_basic"
require_recipe "apache2"
require_recipe "apache2::mod_php5"
require_recipe "apache2::mod_rewrite"
require_recipe "apache2::mod_ssl"
require_recipe "php"
require_recipe "xdebug"

package "nodejs"
package "npm"
package "git-core"
package "memcached"
package "sqlite"

# Install PHP Extensions
package "php5-intl"
package "php5-curl"
package "php5-sqlite"
package "php5-gd"
package "php5-memcache"
package "php5-mysql"
package "php-apc"

# These can be defined in the Vagrantfile to install some extra needed packages
node[:app][:extra_packages].each do |extra_package|
  package extra_package
end

execute "install_composer" do
  cwd "/tmp"
  user "root"
  group "root"
  command "curl -s https://getcomposer.org/installer | php && mv /tmp/composer.phar /usr/local/bin/composer"
end

file "/etc/php5/apache2/conf.d/upload_path.ini" do
  owner "root"
  group "root"
  content "upload_tmp_dir = /tmp/web-app"
  action :create
end

apache_site "000-default" do
  enable false
end

web_app "localhost" do
  server_name node[:app][:server_name]
  server_aliases node[:app][:server_aliases]
  docroot node[:app][:docroot]
end

group "vboxsf" do
  members 'vagrant'
  append true
end

# This fixes a bug in Ubuntu 11.10
file "/etc/php5/conf.d/sqlite.ini" do
  action :delete
end
