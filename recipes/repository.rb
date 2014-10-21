apt_repository "gearmand" do
  uri node['gearman']['repository']['uri']
  deb_src node['gearman']['repository']['deb_src']
  distribution node['gearman']['repository']['distribution']
  components node['gearman']['repository']['components']
  keyserver node['gearman']['repository']['keyserver']
  key node['gearman']['repository']['key']
  action :add
end
