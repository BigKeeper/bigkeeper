require 'engine/parse_para.rb'
require 'engine/parse_engine.rb'
require 'big_keeper/util/bigkeeper_parser'

module BigKeeper
  def self.branch_factory(name)
    version = BigkeeperParser.version if version == 'Version in Bigkeeper file'
    user = ParseEngine.user
    full_name = "feature/#{version}_#{user}_#{name}"
    full_name
  end
end