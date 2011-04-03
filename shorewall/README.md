Description
===========

Shorewall is a rather comprehensive and easy-to-use abstraction layer on top of
iptables.


Requirements
============

This cookbook currently uses the `yumrepo` module to install the EPEL
repository, and is therefore CentOS-specific.

The library functions anticipate a network topology in which a cluster of
servers have interconnects over a "private" network which is sufficiently
insecure that a firewall is appropriate to control connections from that
subnet. (This particularly applies to services such as memcached which expect
security to handled at a different layer). However, the module is expected to
remain useful in other scenarios as well.


Capabilities
============

Creates pretty Shorewall configuration files intended to be aesthetically
comparable to hand-written ones.

The following is a typical example of output (in this case, for a rules file):

    #
    # Shorewall version 4 - Rules File
    #
    # For information on the settings in this file, type "man shorewall-rules"
    #
    # The manpage is also online at
    # http://www.shorewall.net/manpages/shorewall-rules.html
    #
    ############################################################################################################################
    #ACTION         SOURCE          DEST            PROTO   DEST    SOURCE          ORIGINAL        RATE            USER/   MARK
    #                                                       PORT    PORT(S)         DEST            LIMIT           GROUP
    #SECTION ESTABLISHED
    #SECTION RELATED
    SECTION NEW

    # Allow all from VM host
    ACCEPT          net:10.0.2.2    fw              -       -       -               -               -               -       -

    # Incoming SSH to firewall
    ACCEPT          all             fw              tcp     22      -               -               -               -       -

    # Allow database load-balancer db1.vguest access to repmgr monitor
    ACCEPT          lan:192.168.123.10 \
                                    fw              tcp     5480    -               -               -               -       -

Note how line continuations are added as necessary to keep column alignment in place.


Usage
=====

Typical usage from another module is expected to look like the following:

    add_shorewall_rules(
      match_nodes=[
        ['recipes:tippr_db\:\:haproxy', { :name => 'database load-balancer' }],
        ['roles:monitoring', { :name => 'monitoring server' }]
      ],
      rules={
        :description => proc { |data| "Allow #{data[:match][:name]} #{data[:node].name} access to repmgr monitor" },
        :action => :ACCEPT,
        :source => proc { |data| "lan:#{data[:local_address]}" },
        :dest => :fw,
        :proto => :tcp,
        :dest_port => 5480
      }
    )

...in the above case, we're using the `add_shorewall_rules` helper to add an
`ACCEPT` rule for each host which matches either the `tippr_db::haproxy` recipe
or the `monitoring` role (with different comments depending on which role
matched). If a single host matches twice, only a single rule (for each of its
internal IP addresses) is added.

Notably, any of the values in the `rules` hash can be a block, in which case it
is executed with an argument containing both the match metadata passed to the
`match_nodes` argument and the matched node retrieved by the search operation.

Alternately, an explicit rule (or policy) can be added as follows:

    # Give ALL hosts in lan zone access to logstash
    node.override[:shorewall][:rules] << {
      :description => "Access to logstash web server",
      :action => :ACCEPT,
      :source => :lan,
      :dest => :fw,
      :proto => :tcp,
      :dest_port => 9292
    }

Again: Only address matching one of the networks defined in
`shorewall/private_ranges` will be added by the `add_shorewall_rules` helper.

Attributes
==========

*Important:* Many of these are defined at the `override` level rather than the
`default` level. This is done such that `node[:shorewall][:zones] << { ... }`
works as you'd expect.

* `shorewall/default_interface_settings` - Default settings to be used in
  filling out the `interfaces` file. May be overwritten on a per-interface basis.
* `shorewall/enabled` - Boolean (also accepts string versions of true/false);
  whether we actually start the firewall after configuring it.
* `shorewall/private_ranges` - IP address ranges considered eligible as private
  interconnect addresses.
* `shorewall/zone_hosts/ZONE` - if this starts with `search:`, the remainder is
  used as a search expression to identify hosts which should be considered
  members of this zone (when populating the shorewall `hosts` file). Otherwise,
  it can be a CIDR address (as `192.168.0.0/16` or `0.0.0.0/0`) to refer to a
  subnet.
* `shorewall/zone_interfaces/ZONE` - maps from a shorewall zone name to the
  Ethernet interface serving that zone. If multiple zones are mapped to the
  same interface, then that interface will be distinguished via the shorewall
  `hosts` file.
* `shorewall/rules`, `shorewall/policy`, `shorewall/hosts`,
  `shorewall/interfaces` all correspond directly to the relevant upstream
  configuration files.

For more details, see the `attributes/default.rb` file.

Limitations
===========

Patches to address any of these items would be gratefully accepted.

* Includes a hardcoded, non-configurable versions of the `shorewall.conf` file.
* Searches retrieve far more information (entire nodes) than is actually
  needed.
* Support for non-CentOS targets should be both worthwhile and straightforward.
* Not all of shorewall's configuration is mapped.
* No thought has been given to IPv6 support.
