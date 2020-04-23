#!/usr/bin/env ruby

require 'big_keeper/version'

require 'big_keeper/util/bigkeeper_parser'
require 'big_keeper/util/git_operator'
require 'big_keeper/util/verify_operator'

require 'big_keeper/model/gitflow_type'

require 'big_keeper/command/feature&hotfix'
require 'big_keeper/command/release'
require 'big_keeper/command/pod'
require 'big_keeper/command/spec'
require 'big_keeper/command/image'
require 'big_keeper/command/init'
require 'big_keeper/command/client'
require 'big_keeper/service/git_service'
require 'big_keeper/util/leancloud_logger'

require 'engine/parse_engine'
require 'gli'

require 'flow/git_flow'
require 'flow/command_flow'
require 'flow/podfile_flow'
require 'flow/pod_flow'
require 'flow/gradle_flow'

require 'node/git_node'
require 'engine/parse_para'
require 'engine/parse_flow'
require 'engine/parse_plugins'

include GLI::App

module BigKeeper
  # Your code goes here...
  program_desc 'Efficiency improvement for iOS&Android module development, iOSer&Android using this tool can make module development easier.'

  flag %i[p path], default_value: './'
  flag %i[v ver], default_value: 'Version in Bigkeeper file'
  flag %i[u user], default_value: GitOperator.new.user
  flag %i[l log], default_value: true

  def BigKeeper.analysis_config_file
    current_path = current_word_path
    ParseEngine.parse_config(current_path.chop)
    ParseEngine.parse_plugin(current_path.chop)
    @cmd = ParseEngine.short_command_list()
  end

  BigKeeper.analysis_config_file()

  if VerifyOperator.already_in_process?
    p %Q(There is another 'big' command in process, please wait)
    exit
  end

  if !GitflowOperator.new.verify_git_flow_command
    p %Q('git-flow' not found, use 'brew install git-flow' to install it)
    exit
  end

  pre do |global_options, command, options, args|
    LeanCloudLogger.instance.start_log(global_options, args)
    ParseEngine.save_global_options(global_options)
  end

  post do |global_options, command, options, args|
    is_show_log = true
    if global_options[:log] == 'true'
      is_show_log = false
    end
    LeanCloudLogger.instance.end_log(true, is_show_log)
  end

  # feature_and_hotfix_command(GitflowType::FEATURE)

  # feature_and_hotfix_command(GitflowType::HOTFIX)

  # release_command

  # pod_command

  # spec_command

  # image_command

  # init_command

  # client_command

  for cmd in @cmd do
    # desc 'Show version of bigkeeper'
    command cmd do |cmd|
      cmd.action do |global_options, options, args|
        input_cmd = "#{cmd.name}"
        if args.join(' ').length > 0
          input_cmd += ' '
          input_cmd += args.join(' ')
        end
        
        ParseEngine.parse_command(input_cmd)
        BigkeeperParser.parse("#{ParseEngine.user_path}/Bigkeeper")
        
        match_command = ParseEngine.command_match(input_cmd)
        for flow in ParseFlow.load_command_flow do
          flow_input = ParseFlow.get_command_input(flow)
          if flow.end_with?(".rb", ".py", ".sh")
            ParsePlugins.execute(flow)
          else
            if flow_input
              eval("#{flow}(#{flow_input})")
            else
              eval("#{flow}()")  
            end
          end
        end
      end
    end
  end

  desc 'Show version of bigkeeper'
  command :version do |version|
    version.action do |global_options, options, args|
      LeanCloudLogger.instance.set_command("version")
      p "bigkeeper (#{VERSION})"
    end
  end

  exit run(ARGV)
end
