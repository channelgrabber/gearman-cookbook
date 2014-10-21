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

node.default['gearman']['server']['args'] = "--port=#{node['gearman']['server']['port']} \
  --verbose=#{node['gearman']['server']['verbosity']}#{node['gearman']['server']['params']} \
  --syslog -l /var/log/gearmand.log"

if node['gearman']['server']['source']
  include_recipe "gearman::server-source"
else
  [ "gearman-job-server", "libgearman-dev" ].each do |p|
    package p
  end
end

template '/etc/init/gearman-job-server.conf' do
  source 'gearmand.upstart.erb'
  owner 'root'
  group 'root'
  mode 0755
  variables ({
      :params => '--config-file /etc/default/gearman-job-server'
  })
  notifies :restart, "service[gearmand]"
end

template '/etc/default/gearman-job-server' do
  source 'gearmand.init.erb'
  owner 'root'
  group 'root'
  mode 0755
  variables ({
      :params => node['gearman']['server']['args']
  })
  notifies :restart, "service[gearmand]"
end

service 'gearmand' do
  service_name 'gearman-job-server'
  provider Chef::Provider::Service::Upstart
  supports :restart => true, :status => true
  action [:enable, :start]
end
