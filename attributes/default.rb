#
# Cookbook Name:: gearman
# Attributes:: default
#
# Copyright 2012, Cramer Development
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

default['gearman']['server']['enabled'] = true
default['gearman']['server']['source'] = true
default['gearman']['server']['release'] = '1.2'
default['gearman']['server']['version'] = '1.1.8'
default['gearman']['server']['verbosity'] = 'ERROR'
default['gearman']['server']['tmp'] = '/tmp'
default['gearman']['server']['user'] = 'gearman'
default['gearman']['server']['group'] = 'gearman'
default['gearman']['server']['port'] = 4730
default['gearman']['server']['tools'] = 1
default['gearman']['server']['log_dir'] = value_for_platform(
  [ 'centos', 'redhat', 'fedora' ] => {'default' => '/var/log/gearmand'},
  'default' => '/var/log/gearman-job-server'
)
default['gearman']['server']['log_level'] = 'INFO'
default['gearman']['server']['data_dir'] = '/var/lib/gearman'
default['gearman']['server']['params'] = ''

default['gearman']['repository'] = {
    'uri' => 'http://ppa.launchpad.net/ondrej/pkg-gearman/ubuntu',
    'deb_src' => true,
    'distribution' => `lsb_release -cs`.strip,
    'components' => ['main'],
    'keyserver' => 'keyserver.ubuntu.com',
    'key' => 'E5267A6C'
}

default['gearman']['php']['version'] = '1.1.2'
