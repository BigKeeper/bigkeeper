require 'engine/parse_para.rb'
require 'node/git_node.rb'
require 'node/podfile_node.rb'

module BigKeeper
  def self.feature_start_pre(flow_inputs)
    modules = 'modules';
    for input in flow_inputs
      if modules == input
        modules = ParsePara.get_flow_para('modules').split(' ')
      end
    end

    path = ParseEngine.user_path
    user = ParseEngine.user

    ModuleCacheOperator.new(path).clean_modules

    ModuleCacheOperator.new(path).cache_path_modules(modules, modules, [])
    modules = ModuleCacheOperator.new(path).remain_path_modules

    ParsePara.add_para('modules', modules.join(' '))
          
    DepService.dep_operator(path, user).backup
  end

  def self.feature_update_pre(flow_inputs)
    add_modules = 'add_modules';
    del_modules = 'del_modules';

    path = ParseEngine.user_path

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

    # Verify input modules
    add_modules = BigkeeperParser.verify_modules(add_modules)
    del_modules = BigkeeperParser.verify_modules(del_modules)

    # add_modules = modules - current_modules
    current_modules = ModuleCacheOperator.new(path).all_path_modules
    modules = current_modules + add_modules

    p "current_modules = #{current_modules}"
    p "add_modules = #{add_modules}"
    p "del_modules = #{del_modules}"
    p "modules = #{modules}"

    # Clean module cache
    # ModuleCacheOperator.new(path).clean_modules
    ModuleCacheOperator.new(path).cache_path_modules(modules, add_modules, del_modules)
    remain_path_modules = ModuleCacheOperator.new(path).remain_path_modules

    ParsePara.add_para('modules', add_modules.join(' '))
    ParsePara.add_para('del_modules', del_modules.join(' '))
    Dir.chdir(path) do
      branch_name = current_branch()
      ParsePara.add_para('branch_name', branch_name)
    end
  end

end