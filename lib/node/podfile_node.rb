require 'engine/parse_para.rb'

module BigKeeper
  def self.normal_pod_install
    IO.popen("pod install") do |io|
      io.each do |line|
        p line
      end
    end
    
    Logger.highlight('Finish pod install.')
  end
end