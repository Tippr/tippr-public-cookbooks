require 'set'

include_recipe "yumrepo::epel"

package "shorewall" do
  action :install
end

## FIXME: local logic below

zones_per_interface = {}
node[:shorewall][:zone_interfaces].each_pair do |zone,interface|
  if not zones_per_interface.has_key?(interface)
    zones_per_interface[interface] = SortedSet.new
  end
  zones_per_interface[interface].add(zone)
end

default_settings = node[:shorewall][:default_interface_settings].to_hash
zones_per_interface.each_pair do |interface,zones|
  if zones.length > 1
    node.override[:shorewall][:interfaces] << default_settings.merge({
      :interface => interface
    })
    zones.each do |zone|
      zone_hosts = node[:shorewall][:zone_hosts][zone]
      if zone_hosts != nil
        if zone_hosts =~ /^search:(.*)$/
          search_exp = Regexp.last_match(1)
          addresses = get_private_addresses(search_exp).map {|other_node, address| address}.join(',')
        else
          addresses = zone_hosts
        end
        node.override[:shorewall][:hosts] << {
          :zone => zone,
          :hosts => "#{interface}:#{addresses}"
        }
      end
    end
  else
    node.override[:shorewall][:interfaces] << default_settings.merge({
      :zone => zones.to_a[0],
      :interface => interface
    })
  end
end

template "/etc/shorewall/hosts" do
  source "hosts.erb"
  mode 0600
  owner "root"
  group "root"
  notifies :restart, "service[shorewall]"
end

template "/etc/shorewall/interfaces" do
  source "interfaces.erb"
  mode 0600
  owner "root"
  group "root"
  notifies :restart, "service[shorewall]"
end

template "/etc/shorewall/policy" do
  source "policy.erb"
  mode 0600
  owner "root"
  group "root"
  notifies :restart, "service[shorewall]"
end

template "/etc/shorewall/rules" do
  source "rules.erb"
  mode 0600
  owner "root"
  group "root"
  notifies :restart, "service[shorewall]"
end

template "/etc/shorewall/zones" do
  source "zones.erb"
  mode 0600
  owner "root"
  group "root"
  notifies :restart, "service[shorewall]"
end

shorewall_enabled = [true, "true"].include?(node[:shorewall][:enabled])
if shorewall_enabled
  template "/etc/shorewall/shorewall.conf"
end

service "shorewall" do
  supports [ :status, :restart ]
  if shorewall_enabled
    action [:start, :enable]
  end
end

# vim: ai et sts=2 sw=2 sts=2
