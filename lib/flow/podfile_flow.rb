require 'engine/parse_para.rb'
require 'node/git_node.rb'

module BigKeeper
  def self.change_to_path(flow_inputs)
    p 'change_to_path'
    branch_name = 'branch_name';
    modules = 'modules';
    for input in flow_inputs
      if branch_name == input
        branch_name = ParsePara.get_flow_para('branch_name')
      end
  
      if modules == input
        modules = ParsePara.get_flow_para('modules').split(' ')
      end
    end
  
    if branch_name == 'branch_name'
      Logger.error("please input the require parameter branch_name.")
    end
  
    path = ParseEngine.user_path
    user = ParseEngine.user
      
    # Start modules feature and modify module as path

    p "modules change_to_path = #{modules}"
    if modules
      for module_name in modules
        ModuleService.new.new_add(path, user, module_name)
      end
    end
  end

  def self.change_to_git(flow_inputs)
    p 'change_to_git'
    branch_name = 'branch_name';
    del_modules = 'del_modules';

    for input in flow_inputs
      if branch_name == input
        branch_name = ParsePara.get_flow_para('branch_name')
      end
  
      if del_modules == input
        del_modules = ParsePara.get_flow_para('del_modules').split(' ')
      end
    end

    p "del_modules = #{del_modules}"
  
    if branch_name == 'branch_name'
      Logger.error("please input the require parameter branch_name.")
    end

    path = ParseEngine.user_path
    user = ParseEngine.user

    # current_modules = ModuleCacheOperator.new(path).current_path_modules

    # # Verify input modules
    # modules = BigkeeperParser.verify_modules(modules)

    # ModuleCacheOperator.new(path).add_git_module(modules)
    # ModuleCacheOperator.new(path).del_path_module(modules)

    p "modules change_to_git = #{del_modules}"
    if del_modules
      for module_name in del_modules
        ModuleService.new.new_del(path, user, module_name, branch_name)
      end
    end
  end

end
