packages = [ 
  "gcc", "autoconf", "bison", "flex", "libtool", "make", "libboost-all-dev", "libcurl4-openssl-dev", "curl",
  "libevent-dev", "memcached", "uuid-dev", "libtokyocabinet-dev", "libtokyocabinet9", "gperf", "libcloog-ppl0"
]
packages.each do |p|
  package p do
    action :install
  end
end

release = node['gearman']['server']['release']
version = node['gearman']['server']['version']
tmp = node['gearman']['server']['tmp']

remote_file "#{tmp}/gearmand-#{version}.tar.gz" do
  not_if "/usr/local/sbin/gearmand --version | grep -q '#{version}'"
  source "https://launchpad.net/gearmand/#{release}/#{version}/+download/gearmand-#{version}.tar.gz"
end

bash "install_gearman" do
  not_if "/usr/local/sbin/gearmand --version | grep -q '#{version}'"
  cwd "#{tmp}"
  code <<cmd
  tar xvzf gearmand-#{version}.tar.gz
  cd gearmand-#{version}
  ./configure --disable-libdrizzle --disable-libmemcached --without-mysql --without-sqlite3 --without-drizzled
  make
  make install
  ldconfig
cmd
end

template '/etc/init/gearman-job-server.conf' do
  source 'gearmand.upstart.erb'
  owner 'root'
  group 'root'
  mode 0755
  variables ({
      :params => '--config-file /etc/default/gearman-job-server'
  })
end

group node['gearman']['server']['group'] do
  action :create
end

user node['gearman']['server']['user'] do
  gid node['gearman']['server']['group']
  action :create
end

directory node['gearman']['server']['data_dir'] do
  owner node['gearman']['server']['user']
  group node['gearman']['server']['group']
  mode 00755
  action :create
end