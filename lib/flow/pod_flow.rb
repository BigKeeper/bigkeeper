require 'node/podfile_node.rb'

module BigKeeper
  def self.pod_install
    Dir.chdir(ParseEngine.user_path) do
      pod_install_fast_mode()
    end
  end 
end