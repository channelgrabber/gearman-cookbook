#
# Author::  Patrick Leckey (<pat.leckey@gmail.com>)
# Cookbook Name:: gearman
# Recipe:: server-rhel
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
packages = value_for_platform(
    %w{ redhat } => {
        :default => []
    },
    %w{ centos } => {
        :default => []
    }
)

file_to_install = value_for_platform(
    %w{ redhat } => { :default => 'gearmand-0.24_x86_64.rpm' },
    %w{ centos } => { :default => 'gearmand-0.24_x86_64.rpm' }
)

install_command = value_for_platform(
    %w{ redhat } => { :default => 'rpm -Uvh' },
    %w{ centos } => { :default => 'rpm -Uvh' }
)

remote_file "#{Chef::Config[:file_cache_path]}/#{file_to_install}" do
  source "https://github.com/cramerdev/packages/raw/master/#{file_to_install}"
  action :create_if_missing
end

remote_file "#{Chef::Config[:file_cache_path]}/#{file_to_install}" do
  source "https://github.com/cramerdev/packages/raw/master/#{file_to_install}"
  action :create_if_missing
end

execute "#{install_command} #{Chef::Config[:file_cache_path]}/#{file_to_install}" do
  creates '/usr/sbin/gearmand'
end

user node['gearman']['server']['user'] do
  comment 'Gearman Job Server'
  home node['gearman']['server']['data_dir']
  shell '/bin/false'
  supports :manage_home => true
end

group node['gearman']['server']['group'] do
  members [node['gearman']['server']['user']]
end

directory node['gearman']['server']['log_dir'] do
  owner node['gearman']['server']['user']
  group node['gearman']['server']['group']
  mode '0775'
end

include_recipe 'supervisor'
supervisor_service 'gearmand' do
  start_command "/usr/sbin/gearmand #{args}"
  variables :user => node['gearman']['server']['user']
  supports :restart => true
  action [:enable, :start]
end
