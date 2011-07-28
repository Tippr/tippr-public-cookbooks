action :create do

  ## BEGIN DEPENDENCIES
  if node["platform"] == 'centos' and node["platform_version"].split('.')[0] == '5'
    ## CentOS 5 only
    package "python26"
    package "python26-distribute"
    package "python26-devel"

    execute "install pip for Python 2.6" do
      command "easy_install-2.6 pip"
      creates "/usr/bin/pip-2.6"
    end
    execute "install virtualenv for Python 2.6" do
      command "pip-2.6 install virtualenv"
      not_if "which virtualenv"
    end
  else
    %w{ python python-devel python-pip python-virtualenv }.each { |pkg| pkg install }
  end

  %w{ git subversion mercurial }.each { |pkg| pkg install } # SCMs usable by pip

  cookbook_file "/usr/local/bin/pip-upgrade-as-needed" do
    cookbook "virtualenv"
    mode 0755
  end
  ## END DEPENDENCIES

  python_exe = new_resource.python_exe
  if python_exe == "python"
    raise "DEBUG: must not be the default value"
  end

  owner = new_resource.owner
  group = (new_resource.group == nil) ? new_resource.group : owner
  directory = new_resource.directory

  reqs_specced = (new_resource.packages != nil)

  if reqs_specced then
    if new_resource.packages.instance_of? String
      requirements_txt = new_resource.packages+"\n"
    elsif new_resource.packages.instance_of? Array
      requirements_txt = (new_resource.packages.join("\n"))+"\n"
    else
      raise "Unhandled requirements specification type"
    end
  else
    requirements_txt = nil
  end

  directory "#{directory}" do
    owner owner
    group group
    action :create
  end

  execute "create virtualenv #{directory}" do
    user owner
    group group
    path new_resource.path
    command "virtualenv -p '#{python_exe}' '#{directory}'"
    creates "#{directory}/bin/python"
  end

  execute "install local pip in #{directory}" do
    user owner
    group group
    path new_resource.path
    command ". #{directory}/bin/activate; export HOME=#{directory}; pip install -e hg+https://bitbucket.org/charles_dyfis_net/pip-local@bc7f04a9f560#egg=pip"
    not_if "bash -c '. #{directory}/bin/activate; export HOME=#{directory}; [[ \"$(pip --version)\" = \"pip 0.8.2 from \"*/virtualenv/src/pip\" \"* ]]'"
  end

  packages_src = new_resource.packages_src
  if packages_src == nil
    packages_src = "#{directory}/requirements.txt"
    file packages_src do
      owner owner
      group group
      action(reqs_specced ? :create : :delete)
      content requirements_txt
    end
  end

  path_cmd="export PATH=\"#{new_resource.path.join(':')}\""
  execute "update packages in #{directory}" do
    user owner
    group group
    path new_resource.path
    not_if "set -x; #{path_cmd}; . #{directory}/bin/activate; export HOME=#{directory}; (env GENERATE_REPORT=1 /usr/local/bin/pip-upgrade-as-needed <#{packages_src} >#{directory}/upgrades-pending); ! test -s #{directory}/upgrades-pending"
    command "set -x; #{path_cmd}; . #{directory}/bin/activate; export HOME=#{directory}; (env APPLY_REPORT=1 /usr/local/bin/pip-upgrade-as-needed <#{directory}/upgrades-pending); mv #{directory}/upgrades-pending #{directory}/upgrades-pending.last; (env GENERATE_REPORT=1 /usr/local/bin/pip-upgrade-as-needed <#{packages_src} >#{directory}/upgrades-pending); ! test -s #{directory}/upgrades-pending"
    action((reqs_specced or packages_src) ? :run : :nothing)
  end
end

# vim: ai et sts=2 sw=2 ts=2
