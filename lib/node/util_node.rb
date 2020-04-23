require 'engine/parse_para.rb'
require 'engine/parse_engine.rb'
require 'big_keeper/util/bigkeeper_parser'

module BigKeeper
  def self.branch_factory(name)
    version = BigkeeperParser.version
    user = ParseEngine.user
    full_name = "feature/#{version}_#{user}_#{name}"
    full_name
  end

  def self.current_word_path
    path = ''
    IO.popen("pwd") do |io|
      io.each do |line|
        path = line
      end
    end
    path
  end
end