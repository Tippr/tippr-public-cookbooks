define :cookbook_rpm do
  include_recipe "cookbook_rpms::bag_keys"
  if params[:name] =~ /(.*)[.]([^.]*)$/ then
    name, arch = $~.captures
  else
    name = params[:name]
    arch = node[:kernel][:machine]
    if arch =~ /i[3-9]86/
      arch='i386'
    end
  end
  directory "/usr/local/share/packages"
  cookbook_file "/usr/local/share/packages/#{name}.#{arch}.rpm"
  yum_package "#{name}" do
    source "/usr/local/share/packages/#{name}.#{arch}.rpm"
  end
end

# vim: ai et sts=2 sw=2 ts=2
