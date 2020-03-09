require 'engine/parse_para.rb'
require 'node/git_node.rb'
require 'node/podfile_node.rb'

module BigKeeper

  def self.new_branch(flow_inputs)
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
    
    Dir.chdir(ParseEngine.user_path) do
      checkout(baseline_branch)
      pull()
      checkout_new_branch(branch_name)
    end

    for module_name in modules do
      module_path = BigkeeperParser.module_full_path(ParseEngine.user_path, ParseEngine.user, module_name)
      Dir.chdir(module_path) do
        checkout(baseline_branch)
        pull()
        checkout_new_branch(branch_name)
      end
    end
  end
  
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

    stash_modules = ModuleCacheOperator.new(path).all_path_modules

    # Stash current branch
    StashService.new.stash_all(path, branch_name, user, stash_modules)

    # Verify input modules
    modules = BigkeeperParser.verify_modules(modules)

    # Clean module cache
    ModuleCacheOperator.new(path).clean_modules

    # Cache all path modules
    ModuleCacheOperator.new(path).cache_path_modules(modules, modules, [])
    modules = ModuleCacheOperator.new(path).remain_path_modules

    # Backup home
    DepService.dep_operator(path, user).backup

    # Start modules feature and modify module as path
    modules.each do |module_name|
      ModuleService.new.new_add(path, user, module_name)
    end

    Dir.chdir(path) do
      verify_push("init #{branch_name}", branch_name)
    end
    
  end

  def self.pod_install
    p "pod_install"
    Dir.chdir(ParseEngine.user_path) do
      pod_install_fast_mode()
    end
  end

end