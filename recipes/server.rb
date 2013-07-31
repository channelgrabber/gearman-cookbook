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

include_recipe "gearman::#{server_recipe}"

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
