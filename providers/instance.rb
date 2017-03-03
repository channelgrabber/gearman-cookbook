def whyrun_supported?
  true
end

use_inline_resources

action :enable do
  service_action(new_resource.name, new_resource.parameters, :enable)
end

action :start do
  service_action(new_resource.name, new_resource.parameters, :start)
end

action :restart do
  service_action(new_resource.name, new_resource.parameters, :restart)
end

action :stop do
  service_action(new_resource.name, new_resource.parameters, :stop)
end

action :disable do
  service_action(new_resource.name, new_resource.parameters, :disable)
end

def service_action(name, parameters, action)
  service = get_service(name, parse_parameters(parameters).reject(&:empty?).join(' '))
  service.run_action(action)
  service.updated_by_last_action?
end

def parse_parameters(parameters)
  parameters.collect do |param, value|
    if value == false
      ''
    elsif value == true || value.empty?
      "#{'-' * [param.length, 2].min}#{param}"
    else
      "#{'-' * [param.length, 2].min}#{param} #{value}"
    end
  end
end

def get_service(name, params)
  if ['centos', 'redhat', 'fedora'].include?(node['platform'])
    get_rhel_service(name, params)
  else
    get_debian_service(name, params)
  end
end

def get_rhel_service(name, params)
  include_recipe 'supervisor'
  supervisor_service name do
    start_command "/usr/sbin/gearmand #{params}"
    variables :user => node['gearman']['server']['user']
    supports :restart => true
    action :nothing
  end
end

def get_debian_service(name, params)
  config = ::File.join('/etc/default', name)
  upstart = ::File.join('/etc/init', "#{name}.conf")
  init = ::File.join('/etc/init.d', name)

  if node['gearman']['server']['source']
    exec = '/usr/local/sbin/gearmand'
  else
    exec = '/usr/sbin/gearmand'
  end

  template config do
    source 'gearmand.init.erb'
    owner 'root'
    group 'root'
    mode 0755
    variables ({
      :params => params
    })
    action :nothing
  end.run_action(:create)

  template upstart do
    source 'gearmand.upstart.erb'
    owner 'root'
    group 'root'
    mode 0644
    variables ({
      :exec => exec,
      :params => "--config-file #{config}"
    })
    action :nothing
  end.run_action(:create)

  link init do
    to '/lib/init/upstart-job'
    link_type :symbolic
    action :nothing
  end.run_action(:create)

  service name do
    provider ::Chef::Provider::Service::Upstart
    action :nothing
  end
end
