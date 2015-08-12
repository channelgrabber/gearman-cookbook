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

if node['gearman']['server']['source']
  include_recipe "gearman::server-source"
else
  include_recipe "gearman::repository"
  [ "gearman-job-server", "libgearman-dev" ].each do |p|
    package p do
      node['gearman']['server']['instances'].each do |name, config|
        notifies :restart, "gearman_instance[#{name}]", :delayed if config.has_key?('enabled') && config['enabled']
      end
    end
  end
end
