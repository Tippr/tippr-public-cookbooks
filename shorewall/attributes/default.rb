
default[:shorewall][:private_ranges] = ['192.168.0.0/16', '172.16.0.0/12', '10.0.0.0/8']

default[:shorewall][:enabled] = false

default[:shorewall][:zone_interfaces][:net] = "eth0"
default[:shorewall][:zone_interfaces][:lan] = "eth0"
default[:shorewall][:zone_hosts][:lan] = "search:*:*"
default[:shorewall][:zone_hosts][:net] = "0.0.0.0/0"

default[:shorewall][:default_interface_settings][:broadcast] = "detect"
default[:shorewall][:default_interface_settings][:options] = "tcpflags,blacklist,routefilter,nosmurfs,logmartians,dhcp"

# zones ordered from most specific to most general
override[:shorewall][:zones] = [
	{ :zone => "fw", :type => "firewall" },
    { :zone => "lan", :type => "ipv4" },
    { :zone => "net", :type => "ipv4" }
]

override[:shorewall][:policy] = [
    { :source => "fw", :dest => "all", :policy => :ACCEPT },
    { :source => "lan", :dest => "fw", :policy => :REJECT, :log => :DEBUG },
    { :source => "all", :dest => "all", :policy => :REJECT }
]

override[:shorewall][:interfaces] = []

override[:shorewall][:hosts] = []

override[:shorewall][:rules] = [
    { :description => "Incoming SSH to firewall",
      :source => "all", :dest => :fw, :proto => :tcp, :dest_port => 22, :action => :ACCEPT }
]

# vim: ai et sts=4 sw=4 ts=4
