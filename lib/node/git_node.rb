require 'engine/parse_para.rb'

module BigKeeper
  def self.checkout(branch_name)
    IO.popen("git checkout #{branch_name}") do |io|
      io.each do |line|
        Logger.error("Checkout #{branch_name} failed.") if line.include? 'error'
      end
    end
  end

  def self.pull
    ## warning: io.read = nil
    IO.popen("git pull") do |io|
      io.each do |line|
        Logger.error("git pull failed.") if line.include? 'error'
      end
    end
  end

  def self.checkout_new_branch(branch_name)
    cmd = "git checkout -b #{branch_name}"
    if has_branch(branch_name)
      cmd = "git checkout #{branch_name}"
    end
    IO.popen("git checkout -b #{branch_name}") do |io|
      io.each do |line|
        Logger.error("Checkout #{branch_name} failed.") if line.include? 'error'
      end
    end
  end

  def self.has_branch(branch_name)
    has_branch = false
    IO.popen("git branch -a") do |io|
      io.each do |line|
        has_branch = true if line.include? branch_name
      end
    end
    has_branch
  end

end

  # def verify_checkout(path, branch_name)
  #     Dir.chdir(path) do
  #       cmd = "git checkout -b #{branch_name}"
  #       if GitOperator.new.has_branch(path, branch_name)
  #         cmd = "git checkout #{branch_name}"
  #       end
  #       IO.popen(cmd) do |io|
  #         io.each do |line|
  #           Logger.error("Checkout #{branch_name} failed.") if line.include? 'error'
  #         end
  #       end
  #     end
  #   end