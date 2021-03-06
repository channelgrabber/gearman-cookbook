#
# Author::  Patrick Leckey (<pat.leckey@gmail.com>)
# Cookbook Name:: gearman
# Recipe:: php
#
# Copyright 2011-2012, Patrick Leckey
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "gearman::repository"
package "libgearman7"
package "libgearman-dev"

# Update the channels
php_pear_channel 'pear.php.net' do
  action :update
end
php_pear_channel 'pecl.php.net' do
  action :update
end

# Install gearman pecl package
php_pear "gearman" do
  version node['gearman']['php']['version']
  action :install
  not_if "php --info | grep -qs 'gearman support => enabled'"
end

# decide on the apache config dir
config_dir = node['php']['ext_conf_dir']

# Place the correct ini file into the PHP config folder
template "#{config_dir}/gearman.ini" do
  source 'gearman.php-ini.erb'
  owner 'root'
  group 'root'
  mode 0644
end
