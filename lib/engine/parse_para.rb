module BigKeeper
  class ParsePara
    attr_accessor :flow, :input_hash
    def initialize(flow)
      @flow = flow
      @input_hash = Hash.new
    end

    def add_input_paraKV(key, value)
      @input_hash.store(key, value)
    end
  end

  class ParseParaUtil
    @@parse_para_list = []
    @@global_options;
    @@user;
    def self.ask_user_input_require_para(flow, paras)
      para_input = ParsePara.new(flow)
      for para in paras do
        Logger.highlight("The flow #{flow} need para named #{para}, please input it:")
        input = STDIN.gets().chop
        para_input.add_input_paraKV(para, input)
      end
      @@parse_para_list << para_input
    end

    def self.parse_para_list
      @@parse_para_list
    end
    
    def self.get_flow_para(flow)
      res = nil;
      for para in @@parse_para_list do
        if flow == para.flow
          res = para
        end
      end
      res
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
