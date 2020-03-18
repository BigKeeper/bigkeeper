require 'big_keeper/util/logger'
require 'yaml'
require 'engine/parse_para'
require 'engine/parse_flow'
require 'engine/parse_plugins'

module BigKeeper
  class ParseEngine
    @@config = {}
    @@global_options;
    @@user;

      ## parse config file
    def self.parse_config(path)
      @@config = {}
      if !path.empty?
          config = path + '/bigkeeper_config.yml'
          Logger.error("Can't find a bigkeeper_config file in current directory.") if !FileOperator.definitely_exists?(config)
          # todo: load default config
          @@config = YAML.load_file(config)     
      end
    end

    def self.parse_plugin(path)
      ParsePlugins.parse_plugin(path)
    end

      ## parse input command
    def self.parse_command(input_command)
      cmd_match_res = ParseEngine.command_match(input_command)
      if !cmd_match_res
        Logger.error("Can't find input command '#{input_command}' in config file.")
      end

      ParseFlow.parse_flow(@@config[cmd_match_res]['flow'])
      
      if @@config[cmd_match_res]['para']
        ParsePara.ask_user_input_require_para(@@config[cmd_match_res]['para'])
      end
    end

      ## 解析配置所有命令
    def self.command_list
      @@config.keys
    end

      ## 解析配置所有命令首个连续指令
    def self.short_command_list
      short_cmds = []
      for command in @@config.keys do
        if command.include? ' '
          short_cmds << command.to_s.split(' ')[0]
        else
          short_cmds << command
        end
      end
      short_cmds
    end

      ## return command flow's para
    def self.command_flow_para(command, flow)
      flow = @@config[command][flow]
      if flow.class == Hash
        flow['para']
      end
    end

      ## 输入 command 与配置 command匹配
    def self.command_match(input_command)
      for command in @@config.keys do
        if input_command  == command
          match_command = command
        end
      end
      match_command
    end

    def self.save_global_options(global_options)
      @@global_options = global_options
    end

    def self.user
      @@global_options['user']
    end

    def self.user_path
      @@global_options['path']
    end

  end
end