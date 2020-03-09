require 'engine/parse_para.rb'
require 'node/git_node.rb'
require 'node/podfile_node.rb'

module BigKeeper

  def self.feature_update_prepare(flow_inputs)
    add_modules = 'add_modules';
    del_modules = 'del_modules';

    path = ParseEngine.user_path

    current_modules = ModuleCacheOperator.new(path).current_path_modules

    for input in flow_inputs
      if add_modules == input
        input_modules = ParsePara.get_flow_para('add_modules').split(' ')
        add_modules = BigkeeperParser.verify_modules(input_modules)
      end

      if del_modules == input
        input_modules = ParsePara.get_flow_para('del_modules').split(' ')
        del_modules = BigkeeperParser.verify_modules(input_modules)
      end
    end

    modules = current_modules + add_modules - del_modules
    ParsePara.add_para('modules', modules.join(' '))

    Dir.chdir(path) do
      branch_name = current_branch()
      ParsePara.add_para('branch_name', branch_name)
    end
  end

end