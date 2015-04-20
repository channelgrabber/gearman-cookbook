#
# Author::  Patrick Leckey (<pat.leckey@gmail.com>)
# Cookbook Name:: gearman
# Recipe:: server-debian
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

params = [
  "--port=#{node['gearman']['server']['port']}",
  "--verbose=#{node['gearman']['server']['verbosity']}",
  node['gearman']['server']['params'],
  "--syslog -l /var/log/gearmand.log"
]

node.default['gearman']['server']['args'] = params.compact.reject(&:empty?).join(" ")

if node['gearman']['server']['source']
  exec = "/usr/local/sbin/gearmand"
  include_recipe "gearman::server-source"
else
  exec = "/usr/sbin/gearmand"
  include_recipe "gearman::repository"
  [ "gearman-job-server", "libgearman-dev" ].each do |p|
    package p do
        notifies :restart, "service[gearman-job-server]", :delayed if node['gearman']['server']['enabled']
    end
  end
end

file '/var/log/gearmand.log' do
  owner node['gearman']['server']['user']
  group node['gearman']['server']['group']
  action :create_if_missing
end

template '/etc/default/gearman-job-server' do
  source 'gearmand.init.erb'
  owner 'root'
  group 'root'
  mode 0755
  variables ({
      :params => node['gearman']['server']['args']
  })
end

template '/etc/init/gearman-job-server.conf' do
  source 'gearmand.upstart.erb'
  owner 'root'
  group 'root'
  mode 0644
  variables ({
      :exec => exec,
      :params => '--config-file /etc/default/gearman-job-server'
  })
end

link '/etc/init.d/gearman-job-server' do
  to '/lib/init/upstart-job'
  link_type :symbolic
end

service 'gearman-job-server' do
  provider Chef::Provider::Service::Upstart
  if node['gearman']['server']['enabled']
    action [:enable, :start]
  else
    action [:stop, :disable]
  end
end

file File.join(node['gearman']['server']['data_dir'], 'restart.lock') do
  action :create_if_missing
  notifies :restart, "service[gearman-job-server]", :delayed if node['gearman']['server']['enabled']
end
