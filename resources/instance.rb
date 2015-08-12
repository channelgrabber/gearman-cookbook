actions :enable, :start, :stop, :disable
default_action [:enable, :start]

attribute :name, :kind_of => String, :name_attribute => true
attribute :params, :kind_of => String, :default => ''
