data_bag('rpm_keys').each do |bag_id|
  key_data = data_bag_item('rpm_keys', bag_id)
  execute "install-key-#{bag_id}" do
    command "rpm --import /etc/pki/rpm-gpg/#{bag_id}"
    not_if "rpm -q #{key_data['rpm_name']}"
    action :nothing
  end
  file "/etc/pki/rpm-gpg/#{bag_id}" do
    content key_data["key"]
    mode 0644
    notifies :run, "execute[install-key-#{bag_id}]", :immediately
  end
end

# vim: ai et sts=2 sw=2 ts=2
