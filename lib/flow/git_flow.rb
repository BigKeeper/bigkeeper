require 'engine/parse_para.rb'
require 'node/git_node.rb'
require 'node/podfile_node.rb'
require 'node/util_node.rb'

module BigKeeper

  def self.home_new_branch(flow_inputs)
    branch_name = 'branch_name';
    for input in flow_inputs
      if branch_name == input
        branch_name = ParsePara.get_flow_para('branch_name')
      end
    end

    if branch_name == 'branch_name'
      Logger.error("please input the require parameter branch_name.")
    end

    branch_name = branch_factory(branch_name)
    
    baseline_branch = BigkeeperParser.global_configs("baselineBranch") 
    
    Dir.chdir(ParseEngine.user_path) do
      verify_checkout(baseline_branch)
      pull()
      verify_checkout(branch_name)
    end
  end

  def self.module_new_branch(flow_inputs)
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

    branch_name = branch_factory(branch_name)
    
    baseline_branch = BigkeeperParser.global_configs("baselineBranch") 
    
    for module_name in modules do
      module_path = BigkeeperParser.module_full_path(ParseEngine.user_path, ParseEngine.user, module_name)
      Dir.chdir(module_path) do
        verify_checkout(baseline_branch)
        pull()
        verify_checkout(branch_name)
      end
    end
  end
  
  def self.module_finish
    path = ParseEngine.user_path
    user = ParseEngine.user
    branch_name = ''

    Dir.chdir(path) do
      branch_name = current_branch()
    end
    
    ModuleCacheOperator.new(path).cache_git_modules(ModuleCacheOperator.new(path).all_path_modules)
    modules = ModuleCacheOperator.new(path).remain_git_modules
    
    if modules
      modules.each do |module_name|
        Logger.highlight("Finish branch '#{branch_name}' for module '#{module_name}'...")

        DepService.dep_operator(path, user).update_module_config(module_name, ModuleOperateType::FINISH)

        module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
        Dir.chdir(module_full_path) do
          verify_push("finish branch #{branch_name}", branch_name)
        end
  
        ModuleCacheOperator.new(path).add_git_module(module_name)
        ModuleCacheOperator.new(path).del_path_module(module_name)
      end
    end
  end

  def self.home_push
    Dir.chdir(ParseEngine.user_path) do
      branch_name = current_branch()
      verify_push("finish branch #{branch_name}", branch_name)
    end
  end

  def self.module_push(flow_inputs)
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

    path = ParseEngine.user_path
    user = ParseEngine.user

    if modules
      modules.each do |module_name|
        module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
        Dir.chdir(module_full_path) do
          verify_checkout(branch_name)
          verify_push("prepare to rebase #{branch_name}", branch_name)
        end
      end
    end
  end

  def self.module_rebase(flow_inputs)
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

    path = ParseEngine.user_path
    user = ParseEngine.user
    baseline_branch = BigkeeperParser.global_configs("baselineBranch") 

    if modules
      modules.each do |module_name|
        module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
        Dir.chdir(module_full_path) do
          verify_checkout(branch_name)
          verify_rebase(baseline_branch, module_name)
        end
      end
    end
  end

  def self.module_pr(flow_inputs)
    modules = 'modules';
    for input in flow_inputs
      if modules == input
        modules = ParsePara.get_flow_para('modules').split(' ')
      end
    end

    path = ParseEngine.user_path
    user = ParseEngine.user
    
    if modules
      modules.each do |module_name|
        module_full_path = BigkeeperParser.module_full_path(path, user, module_name)
        Dir.chdir(module_full_path) do
          system("aone review")
        end
      end
    end
  end

  def self.home_pr
    path = ParseEngine.user_path
    
    Dir.chdir(path) do
      system("aone review")
    end
  end

end
