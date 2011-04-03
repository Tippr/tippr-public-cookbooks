require 'ipaddr'

def private_addresses_for_node(node_def)
  local_addresses = []
  return local_addresses if node_def['network'] == nil # node may have no ohai data yet
  private_ranges = node[:shorewall][:private_ranges].map { |ip_str| IPAddr.new(ip_str) }
  node_def["network"]["interfaces"].each_pair do |ifname, ifdata|
    if ! ifdata["addresses"] ; then next; end
    ifdata["addresses"].keys.each { |ip_str|
      begin
        if private_ranges.any? { |range| range.include?(IPAddr.new(ip_str)) }
          local_addresses << ip_str
        end
      rescue ArgumentError
        nil # not all addresses are IP; ignore exceptions
      end
    }
  end
  return local_addresses
end

def get_private_addresses(search_criteria, mandatory=false)
  # allow access from app servers
  retval = []
  search(:node, search_criteria).each do |matching_node|
    break if matching_node == :node
    private_addresses_for_node(matching_node).each do |interface_address|
      next if not interface_address
      retval << [matching_node, interface_address]
    end
  end
  if mandatory and retval.length == 0
    raise "no matches for mandatory search #{search_criteria}"
  end
  return retval
end

require 'set'
def add_shorewall_rules(match_nodes, rules, mandatory=false)
  done_nodes = Set.new
  match_nodes.each do |search_rule, match_data|
    get_private_addresses(search_rule).each do |matched_node, local_address|
      if done_nodes.include? local_address then
        next
      end
      done_nodes.add local_address
      node.override[:shorewall][:rules] << rules.merge(rules) do |k,v,_|
        if v.is_a? Proc then
          v = v.call({
            :local_address => local_address,
            :match => match_data,
            :node => matched_node
          })
        end
        next v
      end
    end
  end
  if mandatory and done_nodes.length == 0
    raise "no matches for mandatory search"
  end
end

# vim: ai et sts=2 sw=2 ts=2
