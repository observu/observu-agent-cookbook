#
# Cookbook Name:: observu-agent-cookbook
# Recipe:: default
#
# Copyright 2012, MovingLabs
#
# All rights reserved - Do Not Redistribute
#



# Download file
remote_file "#{Chef::Config[:file_cache_path]}/observu_agent.tar.gz" do
  source node[:observu][:agent_download_url]
  action :create_if_missing
end


# Dependencies
case node[:platform]
  when "debian","ubuntu"
    dep_pack = "libwww-perl"
  when "redhat","centos","scientific","fedora","suse"
    dep_pack = "perl-libwww-perl"
end

package dep_pack do
  action :install
end
  


# Create configuration file

template "observu.conf" do
  path "/etc/observu.conf"
  source "observu.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "observu")
end


# Run installer

bash "install_observu_agent" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
  tar -xzf observu_agent.tar.gz
  cd linux_observu_agent
  ./install.sh -s -n
  EOH
  creates "/usr/local/observu/observu_daemon.pl"
end


service "observu" do
  subscribes :restart, resources(:bash => "install_observu_agent")
  supports :restart => true, :start => true, :stop => true
end

# Start daemon

service "observu" do
  action [:enable, :start]
end

