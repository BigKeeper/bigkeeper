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
    has_error = false
    Open3.popen3('git pull') do |stdin , stdout , stderr, wait_thr|
      while line = stdout.gets
        has_error = true if line.include? 'error'
      end
    end

    Logger.error("git pull failed.") if has_error
  end

  def self.verify_checkout(branch_name)
    cmd = "git checkout -b #{branch_name}"
    if has_branch(branch_name)
      cmd = "git checkout #{branch_name}"
    end
    IO.popen(cmd) do |io|
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

  def self.verify_push(comment, branch_name)
    if has_changes || has_commits(branch_name)
      if has_changes
        commit(comment)
        push(branch_name)
      else
        push(branch_name)
      end
    else
      Logger.default("Nothing to push for '#{name}'.")
      push_to_remote(branch_name)
    end
  end

  def self.push(branch_name)
    if has_remote_branch(branch_name)
      `git push`
    else
      push_to_remote(branch_name)
    end
  end

  def self.push_to_remote(branch_name)
    `git push -u #{remote_local_name()} #{branch_name}`
    check_push_success(branch_name, "#{remote_local_name}/#{branch_name}")
  end
  
  def self.verify_rebase(branch_name, name)
    # pull rebased branch
    pull()

    IO.popen("git rebase #{branch_name} --ignore-whitespace") do |io|
      unless io.gets
        Logger.error("#{name} is already in a rebase-apply, Please:\n"\
                      "  1.Resolve it;\n"\
                      "  2.Commit the changes;\n"\
                      "  3.Push to remote;\n"\
                      "  4.Create a MR;\n"\
                      "  5.Run 'finish' again.")
      end
      io.each do |line|
        next unless line.include? 'Merge conflict'
        Logger.error("Merge conflict in #{name}, Please:\n"\
                      "  1.Resolve it;\n"\
                      "  2.Commit the changes;\n"\
                      "  3.Push to remote;\n"\
                      "  4.Create a MR;\n"\
                      "  5.Run 'finish' again.")
      end
    end
    if current_branch() != 'develop' && current_branch() != 'master'
      `git push -f`
    else
      Logger.error("You should not push 'master' or 'develop'")
    end
  end

  def self.has_changes
    has_changes = true
    clear_flag = 'nothing to commit, working tree clean'
    IO.popen("git status") do |io|
      io.each do |line|
        has_changes = false if line.include? clear_flag
      end
    end
    has_changes
  end

  def self.has_commits(branch_name)
    has_commits = false
    IO.popen("git log --branches --not --remotes") do |io|
      io.each do |line|
        has_commits = true if line.include? "(#{branch_name})"
      end
    end
    has_commits
  end

  def self.commit(comment)
    `git add .`
    `git commit -m "#{Logger.formatter_output(comment)}"`
  end

  def self.remote_local_name
    IO.popen("git remote") do |io|
      io.each do |line|
        Logger.error("Check git remote setting.") if line.length == 0
        return line.chomp
      end
    end
  end

  def self.has_remote_branch(branch_name)
    has_branch = false
    IO.popen("git branch -r") do |io|
      io.each do |line|
        has_branch = true if line.include? branch_name
      end
    end
    has_branch
  end

  def self.check_push_success(branch, compare_branch)
    compare_branch_commits = Array.new
    IO.popen("git log --left-right #{branch}...#{compare_branch} --pretty=oneline") do |io|
      io.each do |line|
        compare_branch_commits.push(line) if (line.include? '>') || (line.include? 'fatal')
      end
    end
    if compare_branch_commits.size > 0
      compare_branch_commits.map { |item|
          Logger.default(item)
      }
      Logger.error("#{branch} branch push unsuccess, please check")
    else
      Logger.highlight("#{branch} branch push success")
    end
  end

  def self.current_branch
    `git rev-parse --abbrev-ref HEAD`.chop
  end
end

