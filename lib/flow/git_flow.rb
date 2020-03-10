require 'engine/parse_para.rb'
require 'node/git_node.rb'
require 'node/podfile_node.rb'

module BigKeeper

  def self.home_new_branch(flow_inputs)
    p 'home_new_branch'
    branch_name = 'branch_name';
    for input in flow_inputs
      if branch_name == input
        branch_name = ParsePara.get_flow_para('branch_name')
      end
    end

    if branch_name == 'branch_name'
      Logger.error("please input the require parameter branch_name.")
    end
    
    baseline_branch = BigkeeperParser.global_configs("baselineBranch") 
    
    Dir.chdir(ParseEngine.user_path) do
      verify_checkout(baseline_branch)
      pull()
      verify_checkout(branch_name)
    end
  end

  def self.module_new_branch(flow_inputs)
    p 'module_new_branch'
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
    
    baseline_branch = BigkeeperParser.global_configs("baselineBranch") 
    
    p "modules new  branch #{modules}"
    for module_name in modules do
      module_path = BigkeeperParser.module_full_path(ParseEngine.user_path, ParseEngine.user, module_name)
      Dir.chdir(module_path) do
        verify_checkout(baseline_branch)
        pull()
        verify_checkout(branch_name)
      end
    end
  end
  
end