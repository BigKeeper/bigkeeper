require 'big_keeper/util/logger'

module BigKeeper
  class ListGenerator
    #generate tree print throught console
    def self.generate_tree(file_path, branches_name, version)
      module_branches_dic = {}
      File.open(file_path, 'r') do |file|
        file.each_line do |line|
          if /:/ =~ line.delete('{}"')
            module_branches_dic[$~.pre_match] = $~.post_match.delete('[]"').strip.split(',')
          end
        end
      end
      # p module_branches_dic
      to_tree(module_branches_dic, branches_name, version)
    end

      #generate json print throught console
    def self.generate_json(file_path, branches, version)
      to_json(file_path, branches)
    end

    def self.to_json(file_path, branches_name)
      File.open(file_path, 'r') do |file|
        file.each_line do |line|
          p line
        end
      end
    end

    def self.to_tree(module_branches_dic, branches_name, version)
      p module_branches_dic
      home_name = BigkeeperParser.home_name
      print_all = version == "all versions"
      branches_name.each do |branch_name|
        next unless branch_name.include?(version) || print_all
        Logger.highlight(" #{home_name} - #{branch_name.strip} ")
        module_branches_dic.keys.each do |module_name|
          module_branches_dic[module_name].each do |module_branch|
            if module_branch.include?(branch_name.strip.delete('*'))
              Logger.default("   ├── #{module_name} - #{branch_name.strip}")
                break
            end
          end
        end
      end
    end
  end
end