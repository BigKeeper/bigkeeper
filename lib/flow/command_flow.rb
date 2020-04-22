require 'engine/parse_para.rb'
require 'node/git_node.rb'
require 'node/podfile_node.rb'
require 'node/util_node.rb'
require 'big_keeper/dependency/dep_service'

module BigKeeper
  def self.feature_start_pre(flow_inputs)
    modules = 'modules';
    branch_name = 'branch_name';

    for input in flow_inputs
      if modules == input
        modules = ParsePara.get_flow_para('modules').split(' ')
      end

      if branch_name == input
        branch_name = ParsePara.get_flow_para('branch_name')
      end
    end

    if branch_name == 'branch_name'
      Logger.error("please input the require parameter branch_name.")
    end

    path = ParseEngine.user_path
    user = ParseEngine.user

    ModuleCacheOperator.new(path).clean_modules

    ModuleCacheOperator.new(path).cache_path_modules(modules, modules, [])
    modules = ModuleCacheOperator.new(path).remain_path_modules

    ParsePara.add_para('modules', modules.join(' '))

    branch_name = branch_factory(branch_name)
    ParsePara.add_para('branch_name', branch_name)
          
    DepService.dep_operator(path, user).backup
  end

  def self.feature_start_post(flow_inputs)
    branch_name = 'branch_name';

    for input in flow_inputs
      if branch_name == input
        branch_name = ParsePara.get_flow_para('branch_name')
      end
    end

    Dir.chdir(ParseEngine.user_path) do
      verify_push("init #{branch_name}", branch_name)
      DepService.dep_operator(ParseEngine.user_path, ParseEngine.user).open
    end
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

  def self.feature_finish_pre
    p 'feature_finish_pre'
    path = ParseEngine.user_path
    Dir.chdir(path) do
      branch_name = current_branch()
      p branch_name
      Logger.error("Not a feature branch, exit.") unless branch_name.include? 'feature'

      # Cache git modules
      if ModuleCacheOperator.new(path).all_path_modules.empty?
        Logger.error("Branch '#{branch_name}' is already finished, exit.")
      end
      
      # Push modules changes to remote then rebase
      ModuleCacheOperator.new(path).cache_git_modules(ModuleCacheOperator.new(path).all_path_modules)
      modules = ModuleCacheOperator.new(path).remain_git_modules
      
      ParsePara.add_para('modules', modules.join(' '))
      ParsePara.add_para('branch_name', branch_name)
    end
  end

  def self.feature_publish_pre
    path = ParseEngine.user_path
    Dir.chdir(path) do
      branch_name = current_branch()

      Logger.error("Not a feature branch, exit.") unless branch_name.include? 'feature'

      path_modules = ModuleCacheOperator.new(path).current_path_modules
      Logger.error("You have unfinished modules #{path_modules}, Use 'finish' first please.") unless path_modules.empty?
  
      # Push modules changes to remote then rebase
      modules = ModuleCacheOperator.new(path).current_git_modules
      ParsePara.add_para('modules', modules.join(' '))
      ParsePara.add_para('branch_name', branch_name)
    end
  end

  def self.search(flow_inputs)
    keyword = 'keyword';

    path = ParseEngine.user_path

    for input in flow_inputs
      if keyword == input
        keyword = ParsePara.get_flow_para('keyword')
      end
    end

    cmd = "grep -r #{keyword} #{path}"
    Logger.highlight("execute command: #{cmd}")
    Open3.popen3("grep -r #{keyword} #{path}") do |stdin , stdout , stderr, wait_thr|
      while line = stdout.gets
        Logger.default(line.chop()) unless line.include?('No such file or directory')
      end
    end
    Logger.highlight("search end for #{keyword}")
  end

end