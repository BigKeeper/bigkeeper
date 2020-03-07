require 'engine/parse_para.rb'
require 'node/git_node.rb'

module BigKeeper

  def self.new_branch(parse_para)
    branch_name = parse_para['branch_name']
    p branch_name

    modules = parse_para['modules'].split(' ')
    
    baseline_branch = BigkeeperParser.global_configs("baselineBranch") 
    
    Dir.chdir(ParseParaUtil.user_path) do
      checkout(baseline_branch)
      pull()
      checkout_new_branch(branch_name)
    end

    for module_name in modules do
      p "module name = #{module_name}"
      p "path = #{ParseParaUtil.user_path}"
      p "path = #{ParseParaUtil.user}"
      module_path = BigkeeperParser.module_full_path(ParseParaUtil.user_path, ParseParaUtil.user, module_name)
      p "module_path = #{module_path}"
      Dir.chdir(module_path) do
        checkout(baseline_branch)
        pull()
        checkout_new_branch(branch_name)
      end
    end

    
  end
  
  def self.change_to_path
    p 'change_to_path'
  end

  def self.pod_install
    p 'pod_install'
  end

end