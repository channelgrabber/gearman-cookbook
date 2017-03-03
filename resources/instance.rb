actions :enable, :start, :restart, :stop, :disable
default_action [:enable, :start]

attribute :name, :kind_of => String, :name_attribute => true
attribute :parameters, :kind_of => Hash, :default => {}
