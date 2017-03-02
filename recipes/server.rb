#
# Cookbook Name:: gearman
# Recipe:: server
#
# Copyright 2011, Cramer Development
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

server_recipe = value_for_platform(
    [ "centos", "redhat", "fedora" ] => {"default" => "server-rhel"},
    "default" => "server-debian"
)

tools_packages = value_for_platform(
    [ "centos", "redhat", "fedora" ] => {"default" => ""},
    "default" => "mod-gearman-tools"
)

include_recipe "gearman::repository"
include_recipe "gearman::#{server_recipe}"

directory node['gearman']['server']['log_dir'] do
  recursive true
end

node['gearman']['server']['instances'].each do |name, config|
  params = []
  params << "--port=#{config['port']}" if config.has_key?('port')
  params << "--verbose=#{config['verbosity']}" if config.has_key?('verbosity')
  params << config['params'] if config.has_key?('params')
  params << "--syslog -l #{node['gearman']['server']['log_dir']}/#{name}.log"
  params = params.compact.reject(&:empty?).join(' ')

  file "#{node['gearman']['server']['log_dir']}/#{name}.log" do
    owner node['gearman']['server']['user']
    group node['gearman']['server']['group']
    action :create_if_missing
  end

  gearman_instance name do
    params params
    if config.has_key?('enabled') && config['enabled']
      action [:enable, :start]
    else
      action [:stop, :disable]
    end
  end
end

file File.join(node['gearman']['server']['data_dir'], 'restart.lock') do
  action :create_if_missing
  node['gearman']['server']['instances'].each do |name, config|
    notifies :restart, "gearman_instance[#{name}]", :delayed if config.has_key?('enabled') && config['enabled']
  end
end

package tools_packages do
  action :install
  only_if node['gearman']['server']['user'].equal?(1)
end

package "gearman-tools" do
  action :install
  only_if node['gearman']['server']['user'].equal?(1)
end

logrotate_app 'gearmand' do
  path "#{node['gearman']['server']['log_dir']}/*.log"
  frequency 'daily'
  rotate 4
  create "600 #{node['gearman']['server']['user']} #{node['gearman']['server']['group']}"
end
