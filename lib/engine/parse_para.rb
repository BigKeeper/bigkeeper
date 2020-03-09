module BigKeeper
  class ParaModel
    attr_accessor :key, :input
    def initialize(key, input)
      @key = key
      @input = input
    end
  end

  class ParsePara
    @@paras = []
    def self.ask_user_input_require_para(paras)
      for para in paras do
        Logger.highlight("#{para['descript']}")
        input = STDIN.gets().chop
        para_model = ParaModel.new(para['key'], input)
        @@paras << para_model
      end
    end

    def self.parse_para_list
      @@paras
    end

    def self.get_flow_para(key)
      res = '';
      for para in @@paras do
        if para.key == key
          res = para.input
        end
      end
      res;
    end
  end

end
