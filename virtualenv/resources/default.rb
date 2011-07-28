actions :create, :delete
attribute :directory, :kind_of => String, :name_attribute => true
attribute :packages, :default => nil
attribute :packages_src, :default => nil
attribute :python_exe, :default => "python", :kind_of => String
attribute :owner, :default => "root"
attribute :group, :default => "root"
attribute :path, :default => %w{ /bin /usr/bin /usr/local/bin }, :kind_of => Array
