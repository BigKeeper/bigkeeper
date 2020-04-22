require 'engine/parse_para.rb'
require 'node/git_node.rb'
require 'big_keeper/model/operate_type'

module BigKeeper
  def self.gradle_start
    path = ParseEngine.user_path
    user = ParseEngine.user

    GradleFileOperator.new(path, user).update_home_depends("#{path}/app/build.gradle", "#{path}/settings.gradle", OperateType::START)
  end

  def self.gradle_update
    path = ParseEngine.user_path
    user = ParseEngine.user

    GradleFileOperator.new(path, user).update_home_depends("#{path}/app/build.gradle", "#{path}/settings.gradle", OperateType::UPDATE)
  end

  def self.gradle_finish
    path = ParseEngine.user_path
    user = ParseEngine.user

    GradleFileOperator.new(path, user).update_home_depends("#{path}/app/build.gradle", "#{path}/settings.gradle", OperateType::FINISH)
  end

  def self.gradle_publish
    path = ParseEngine.user_path
    user = ParseEngine.user
    DepGradleOperator.new(path, user).recover
  end
end