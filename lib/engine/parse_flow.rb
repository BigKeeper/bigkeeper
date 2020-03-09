module BigKeeper
  class FlowModel
    attr_accessor :name, :inputs
    def initialize(name, inputs)
      @name = name
      @inputs = inputs
    end
  end

  class ParseFlow
    @@flows = []
    def self.parse_flow(flows)
      # flows is array
      for flow in flows do
        @@flows << FlowModel.new(flow['name'], flow['input'])
      end
    end

    def self.load_command_flow
      flows = []
      for flow in @@flows do
        flows << flow.name
      end
      flows
    end

    def self.get_command_input(flow_name)
      inputs = ''
      for flow in @@flows do
        if flow.name == flow_name
          inputs = flow.inputs
        end
      end
      inputs.split(' ') unless inputs == nil
    end

  end
end